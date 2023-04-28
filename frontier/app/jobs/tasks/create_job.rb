# frozen_string_literal: true

require "docker"
require "securerandom"

class Tasks::CreateJob < ApplicationJob
  TARGET_PATH = "/app/git-repositories"
  private_constant :TARGET_PATH

  IMAGE_TAG = "python-mutator:latest"
  private_constant :IMAGE_TAG

  sidekiq_options retry: false

  def perform(url, branch)
    clone_git_repository(url, branch)
    start_container.attach do |_stream, chunk|
      Rails.logger.debug chunk[0..100] if chunk.present?
    end

    # FIXME
    data = JSON.parse(
      File.read("/app/git-repositories/#{identifier}/result.json")
    )

    if (service_result = Tasks::DetectService.call(data)).success?
      Rails.logger.debug("OK: #{service_result.response.code}")
    else
      Rails.logger.debug("FAIL: #{service_result.exception.inspect}")
    end
  end

  private

    def clone_git_repository(repository_url, branch)
      options = if branch
        { branch: branch }
                else
        {}
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

    def identifier
      @identifier ||= SecureRandom.hex
    end
end
