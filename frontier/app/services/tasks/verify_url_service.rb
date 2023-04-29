# frozen_string_literal: true

require "uri"

class Tasks::VerifyURLService < ApplicationService
  HOSTS_WHITETLIST = %w[
    github.com
  ].freeze

  subject :url

  result_on_failure :reason

  def call
    return failure! reason: :blank if url.blank?

    if (parsed_url = URI.parse(url)) && parsed_url.host.present? && parsed_url.host.to_s.in?(HOSTS_WHITETLIST)
      success!
    else
      failure! reason: :invalid_format
    end
  rescue URI::InvalidURIError
    failure! reason: :invalid_format
  end
end
