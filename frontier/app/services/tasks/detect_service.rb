# frozen_string_literal: true

class Tasks::DetectService < ApplicationService
  subject :task_spec

  def call
    api_client.detect(task_spec)

    true
  rescue StandardError
    false
  end

  private

    def api_client
      @api_client ||= HTTPClient::Detector.new(
        Rails.application.credentials.dig(:services, :detector)
      )
    end
end