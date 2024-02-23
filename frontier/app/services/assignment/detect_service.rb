# frozen_string_literal: true

class Assignment::DetectService < ApplicationService
  input :submission

  output :response
  output :exception

  play :perform_api_request

  private

    def call
      super
    rescue StandardError => e
      self.exception = e
    end

    def perform_api_request
      self.response = api_client.detect(submission)
    end

    def api_client
      @api_client ||= DetectorClient.new(
        Rails.application.credentials.dig(:services, :detector)
      )
    end
end
