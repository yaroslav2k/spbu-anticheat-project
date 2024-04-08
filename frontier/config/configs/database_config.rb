# frozen_string_literal: true

class DatabaseConfig < ApplicationConfig
  config_name :postgres

  attr_config :hostname, :username, :password

  required :hostname, :username, :password
end
