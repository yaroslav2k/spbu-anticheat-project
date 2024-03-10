# frozen_string_literal: true

HealthMonitor.configure do |config|
  config.path = :now

  config.sidekiq
end
