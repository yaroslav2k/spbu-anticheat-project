# frozen_string_literal: true

Rails.application.configure do
  config.credentials.content_path = "config/credentials/test.yml.enc"
  config.credentials.key_path = "config/credentials/test.key"
end
