# frozen_string_literal: true

class RedisConfig < ApplicationConfig
  attr_config :url

  required :url

  validate_url! :url
end
