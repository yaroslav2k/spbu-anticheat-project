# frozen_string_literal: true

class API::SubmissionsController < API::ApplicationController
  before_action :authenticate, :ensure_submission_presence, :ensure_status_presence, only: %i[update]

  def create
    if Submission.create(submission_params)
      render status: :created
    else
      render status: :unprocessable_entity
    end
  end

  def update
    if submission.update(status:)
      head :no_content
    else
      head :server_error
    end
  end

  private

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        ActiveSupport::SecurityUtils.secure_compare(
          token, Rails.application.credentials.api.fetch(:access_token)
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

    def submission_params
      params.fetch(:submission).permit(:author, :assignment_id, :url, :branch)
    end
end
