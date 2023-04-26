# frozen_string_literal: true

class API::ApplicationController < ApplicationController
  skip_before_action :verify_authenticity_token
end