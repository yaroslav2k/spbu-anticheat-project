# frozen_string_literal: true

class API::TasksController < API::ApplicationController
  before_action :ensure_url_presence, only: %i[create]

  def create
    render json: { url: params[:url] }
  end

  private

    def ensure_url_presence
      return if params[:url].present?

      head :unprocessable_entity
    end
end