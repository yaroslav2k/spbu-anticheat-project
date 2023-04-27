# frozen_string_literal: true

require "docker"
require "securerandom"

class Tasks::CreateJob < ApplicationJob
  TARGET_PATH = "/app/git-repositories"
  private_constant :TARGET_PATH

  IMAGE_TAG = "cst-mutator:latest"
  private_constant :IMAGE_TAG

  sidekiq_options retry: false

  def perform(url, branch)
    clone_git_repository(url, branch)
    start_container

    # FIXME
    data = File.read("/app/git-repositories/#{identifier}/result.json")

    Tasks::DetectService.call(data)
  end

  private

    def clone_git_repository(repository_url, branch)
      options = if branch
        { branch: branch }
      else
        {}
      end

      Git.clone(repository_url, TARGET_PATH + "/" + identifier, **options)
    end

    def start_container
      container.start({"Binds": ["spbu-anticheat-project_git-repositories:/app/input"]})
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