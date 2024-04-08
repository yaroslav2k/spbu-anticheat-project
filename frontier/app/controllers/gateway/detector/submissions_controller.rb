# frozen_string_literal: true

class Gateway::Detector::SubmissionsController < Gateway::ApplicationController
  skip_forgery_protection

  before_action :authenticate_request, :ensure_submission_presence, :ensure_status_presence, only: %i[update]

  def update
    if submission.update(status:)
      head :no_content
    else
      head :server_error
    end
  end

  private

    def authenticate_request
      authenticate_or_request_with_http_token do |token, _options|
        ActiveSupport::SecurityUtils.secure_compare(
          token, Frontier.config.detector_config.webhook_access_token
        )
      end
    end

    def ensure_submission_presence
      return if submission

      head :unprocessable_entity
    end

    def ensure_status_presence
      return if status.present?

      head :unprocessable_entity
    end

    def submission
      return @submission if defined?(@submission)

      @submission = Submission.find_by(id:)
    end

    def id = params[:id]

    def status = params.dig(:submission, :status)
end
