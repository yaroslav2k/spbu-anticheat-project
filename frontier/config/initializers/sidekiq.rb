# frozen_string_literal: true

redis_config = Rails.application.credentials.redis

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
