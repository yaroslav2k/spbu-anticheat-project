# frozen_string_literal: true

require_relative "boot"

require "rails"

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

class Frontier
  class Application < Rails::Application
    config.load_defaults 7.0

    config.active_record.schema_format = :sql
    config.active_record.dump_schema_after_migration = false

    config.time_zone = "Europe/Moscow"

    config.generators.system_tests = nil

    config.eager_load_paths << Rails.root.join("lib")

    config.active_job.queue_adapter = :sidekiq

    config.x.ip_address = "127.0.0.1"

    config.i18n.default_locale = :ru
    config.i18n.fallbacks = %i[ru en]
    config.i18n.raise_on_missing_translations = false

    config.autoload_paths += %w[#{config.root}/validators]

    config.require_master_key = false
  end

  def self.config
    Rails.application.config.x
  end
end

require_relative "gem_extensions"
