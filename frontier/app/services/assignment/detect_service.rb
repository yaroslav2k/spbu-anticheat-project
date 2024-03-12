# frozen_string_literal: true

class Assignment::DetectService < ApplicationService
  input :assignment, type: Assignment
  input :submission, type: Submission, allow_nil: true

  output :response
  output :exception

  play :perform_api_request

  def call
    super
  rescue StandardError => e
    self.exception = e
  end

  private

    def perform_api_request
      self.response = api_client.detect(assignment, submission)
    end

    def api_client
      @api_client ||= DetectorClient.new(
        Rails.application.credentials.dig(:services, :detector)
      )
    end
end
