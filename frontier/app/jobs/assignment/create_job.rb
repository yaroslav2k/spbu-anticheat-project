# frozen_string_literal: true

require "docker"
require "securerandom"

class Assignment::CreateJob < ApplicationJob
  TARGET_PATH = "/app/git-repositories"
  IMAGE_TAG = "python-mutator:latest"
  DEFAULT_GIT_BRANCH_NAME = "main"

  private_constant :TARGET_PATH
  private_constant :IMAGE_TAG
  private_constant :DEFAULT_GIT_BRANCH_NAME

  sidekiq_options retry: false

  def perform(submission)
    clone_git_repository(submission.url, submission.branch)

    start_container.attach do |_stream, chunk|
      Rails.logger.debug chunk[0..100] if chunk.present?
    end

    # FIXME: (?)
    data = File.read("/app/git-repositories/#{identifier}/result.json")

    begin
      s3_client.put_object(
        body: data,
        bucket: "development",
        key: "/#{submission.storage_key}",
        content_type: "application/json"
      )
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error e.inspect

      submission.update!(status: :failed)

      return
    end

    if (service_result = Assignment::DetectService.call(submission)).success?
      Rails.logger.debug("OK: #{service_result.response.code}")
    else
      Rails.logger.debug("FAIL: #{service_result.exception.inspect}")
    end
  end

  private

    def clone_git_repository(repository_url, branch)
      options = {}.tap do |hash|
        hash[:branch] = branch if branch.present?
      end

      Git.clone(repository_url, "#{TARGET_PATH}/#{identifier}", **options)
    end

    def start_container
      container.tap do |c|
        c.start({ "Binds": ["spbu-anticheat-project_git-repositories:/app/input"] })
      end
    end

    def container
      @container ||= Docker::Container.create(
        "Image" => IMAGE_TAG,
        "Cmd" => ["/app/input/#{identifier}"],
        "Volumes" => {
          "spbu-anticheat-project_git-repositories" => { "/app/input" => "rw" }
        }
      )
    end

    def s3_client
      @s3_client ||= Aws::S3::Client.new
    end

    def identifier
      @identifier ||= SecureRandom.hex
    end
end
