# frozen_string_literal: true

class Tasks::DetectService < ApplicationService
  subject :task_spec

  result_on_success :response
  result_on_failure :exception

  def call
    response = api_client.detect(task_spec)

    success! response: response
  rescue StandardError => e
    failure! exception: e
  end

  private

    def api_client
      @api_client ||= DetectorClient.new(
        Rails.application.credentials.dig(:services, :detector)
      )
    end
end