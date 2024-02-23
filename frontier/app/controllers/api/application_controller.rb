# frozen_string_literal: true

class API::ApplicationController < ApplicationController
  before_action :authenticate

  skip_before_action :verify_authenticity_token

  private

    def authenticate
      authenticate_or_request_with_http_token do |token, _options|
        ActiveSupport::SecurityUtils.secure_compare(token, Rails.application.credentials.api.fetch(:access_token))
      end
    end
end
