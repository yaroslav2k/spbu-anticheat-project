# frozen_string_literal: true

class HealthMonitor::Providers::Docker < HealthMonitor::Providers::Base
  DockerRuntimeUnavailableError = Class.new(StandardError)

  def check!
    Docker.version
  rescue StandardError => e
    raise DockerRuntimeUnavailableError, e
  end
end
