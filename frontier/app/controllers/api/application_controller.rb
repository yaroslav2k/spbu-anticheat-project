# frozen_string_literal: true

class API::ApplicationController < ApplicationController
  include ActionController::HttpAuthentication::Basic

  before_action :authenticate_request

  skip_before_action :verify_authenticity_token

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
