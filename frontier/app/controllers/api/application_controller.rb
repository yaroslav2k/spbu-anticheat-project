# frozen_string_literal: true

class API::ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :authenticate_request

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  private

    attr_reader :current_user

    def authenticate_request
      @current_user = authenticate_with_http_basic do |username, password|
        User.find_by(username:).then do |user|
          user if user.valid_password?(password)
        end
      end

      head :unauthorized unless current_user
    end
end
