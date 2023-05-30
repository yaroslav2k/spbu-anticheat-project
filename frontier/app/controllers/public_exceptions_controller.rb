class PublicExceptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def internal_error
    render json: params.to_unsafe_h
  end
end
