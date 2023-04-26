# frozen_string_literal: true

class API::TasksController < API::ApplicationController
  before_action :ensure_url_validity, only: %i[create]

  def create
    enqueue_task_creation_job

    head :accepted
  end

  private

    def ensure_url_validity
      return if (service_result = Tasks::VerifyURLService.call(params[:url])).success?

      render status: :unprocessable_entity, json: {
        error: {
          url: service_result.reason || :unknown
        }
      }
    end

    def enqueue_task_creation_job
      Tasks::CreateJob.perform_later(params[:url])
    end
end