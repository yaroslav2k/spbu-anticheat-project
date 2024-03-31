# frozen_string_literal: true

require "redis"

HealthMonitor.configure do |config|
  config.path = :current

  config.redis.configure do |redis_config|
    redis_config.url = Rails.application.credentials.services.redis.fetch(:url)
  end

  config.sidekiq

  config.add_custom_provider(HealthMonitor::Providers::Docker)
end
