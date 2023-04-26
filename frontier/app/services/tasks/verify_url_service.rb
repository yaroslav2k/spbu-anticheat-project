# frozen_string_literal: true

require "uri"

class Tasks::VerifyURLService < ApplicationService
  subject :url

  result_on_failure :reason

  def call
    return failure! reason: :blank unless url.present?

    (parsed_url = URI.parse(url)) && parsed_url.host.present?

    success!
  rescue URI::InvalidURIError
    failure! reason: :invalid_format
  end
end