# frozen_string_literal: true

class DetectorConfig < ApplicationConfig
  attr_config :base_uri, :access_token

  required :base_uri, :access_token

  validate_url! :base_uri
end
