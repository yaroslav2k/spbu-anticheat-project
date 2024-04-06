# frozen_string_literal: true

require "docker"

class Submission::ProcessJob < ApplicationJob
  TARGET_PATH = "/app/git-repositories"
  IMAGE_TAG = "python-mutator:latest"
  DEFAULT_GIT_BRANCH_NAME = "main"

  DetectorServiceFailureError = Class.new(StandardError)

  private_constant :TARGET_PATH
  private_constant :IMAGE_TAG
  private_constant :DEFAULT_GIT_BRANCH_NAME

  sidekiq_options retry: false

  include Memery

  def perform(submission)
    @submission = submission

    if submission.of_type.git?
      process_git_submission
    elsif submission.of_type.files_group?
      process_files_group_submission
    else
      raise ArgumentError, "Unexpected submission type #{submission.of_type.inspect}"
    end
  end

  private

    attr_reader :submission

    def process_git_submission
      handle_failure do
        clone_git_repository(submission.url, submission.branch)

        container = create_container([submission.url, submission.branch].join(":")).start.tap(&:attach)

        s3_client.put_object(
          body: File.read(manifest_filepath(identifier)),
          bucket: Rails.env,
          key: "/#{submission.storage_key}",
          content_type: "application/json"
        )

        service_result = Assignment::DetectService.call(
          assignment: submission.assignment,
          submission:
        )

        raise service_result.exception if service_result.exception

        container.tap(&:stop).tap(&:remove)
      end
    end

    def process_files_group_submission
      handle_failure do
        uploads_directoty = "#{TARGET_PATH}/#{identifier}"
        FileUtils.mkdir_p(uploads_directoty)

        submission.uploads.find_each do |upload|
          File.open("#{uploads_directoty}/#{upload.filename}", "wb") do |file|
            s3_client.get_object(bucket: Rails.env, key: upload.storage_key) { |chunk| file.write(chunk) }
          end
        end

        container = create_container(submission.id).start.tap(&:attach)

        s3_client.put_object(
          body: File.read(manifest_filepath(identifier)),
          bucket: Rails.env,
          key: "/#{submission.storage_key}",
          content_type: "application/json"
        )

        service_result = Assignment::DetectService.call(
          assignment: submission.assignment,
          submission:
        )

        raise service_result.exception if service_result.exception

        container.tap(&:stop).tap(&:remove)
      end
    end

    def manifest_filepath(identifier)
      "/app/git-repositories/#{identifier}/.manifest.json"
    end

    def mutator_manifest_filepath(identifier)
      "/app/input/#{identifier}/.manifest.json"
    end

    def clone_git_repository(repository_url, branch)
      options = {}.tap do |hash|
        hash[:branch] = branch if branch.present?
      end

      Git.clone(repository_url, "#{TARGET_PATH}/#{identifier}", **options)
    end

    memoize def create_container(submission_identifier)
      Docker::Container.create(
        "Image" => IMAGE_TAG,
        "HostConfig" => { "Binds" => ["spbu-anticheat-project_git-repositories:/app/input"] },
        "Cmd" => [
          "/app/input/#{identifier}",
          "--identifier",
          submission_identifier,
          "--output",
          mutator_manifest_filepath(identifier)
        ]
      )
    end

    def s3_client = @s3_client ||= Aws::S3::Client.new

    def telegram_bot_client = Telegram::Bot::Client.default

    def handle_failure
      yield
    rescue Git::FailedError, Aws::S3::Errors::ServiceError, Errno::ENOENT => e
      submission.update!(status: "failed")

      Rails.logger.error(e.inspect)
    rescue StandardError => e
      submission.update!(status: "failed")

      Rails.logger.error(e.inspect)

      raise e
    end

    def identifier = @identifier ||= submission.id
end
