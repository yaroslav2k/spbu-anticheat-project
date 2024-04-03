# frozen_string_literal: true

redis_config = Frontier.config.redis_config.to_h

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.concurrency = 1
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
