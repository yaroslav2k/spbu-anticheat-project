# frozen_string_literal: true

class Assignment::DetectService < ApplicationService
  input :assignment, type: Assignment
  input :submission, type: Submission, allow_nil: true

  output :response
  output :exception

  play :perform_api_request

  def call
    Rails.logger.info("Started #{self.class.name}")

    super
  rescue StandardError => e
    self.exception = e
  end

  private

    def perform_api_request
      self.response = api_client.detect_clones(assignment, submission)
    end

    def api_client
      @api_client ||= Detector::Client.new(Frontier.config.detector_config)
    end
end
