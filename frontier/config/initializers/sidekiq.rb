# frozen_string_literal: true

redis_config = Rails.application.credentials.services.redis

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.concurrency = 1
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
