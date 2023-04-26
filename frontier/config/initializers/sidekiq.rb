# frozen_string_literal: true

redis_config = { url: ENV.fetch("REDIS_URL", "redis://redis:6379") }

Sidekiq.configure_server do |config|
  config.redis = redis_config
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
