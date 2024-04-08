# frozen_string_literal: true

require "redis"

HealthMonitor.configure do |config|
  config.path = :current

  config.redis.configure do |redis_config|
    redis_config.url = Frontier.config.redis_config.url
  end

  config.sidekiq

  config.add_custom_provider(HealthMonitor::Providers::Docker)
end
