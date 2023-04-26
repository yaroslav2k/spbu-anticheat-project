# frozen_string_literal: true

class API::TasksController < API::ApplicationController
  before_action :ensure_url_presence, only: %i[create]

  def create
    enqueue_task_creation_job

    head :accepted
  end

  private

    def ensure_url_presence
      return if params[:url].present?

      head :unprocessable_entity
    end

    def enqueue_task_creation_job
      Tasks::CreateJob.perform_later(params[:url])
    end
end