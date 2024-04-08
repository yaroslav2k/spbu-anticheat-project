# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require "simplecov"
SimpleCov.start do
  enable_coverage :branch

  add_group "lib", "lib"
  %w[models controllers jobs services decorators validators helpers].each do |group|
    add_group group, "app/#{group}"
  end

  add_filter "app/admin"
  add_filter "config"
  add_filter "lib/tasks"
  add_filter "spec"
  add_filter "db"
end

require "rails_helper"

require "enumerize/integrations/rspec"

Dir["#{__dir__}/support/**/*.rb"].each { require_relative(_1) }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.infer_spec_type_from_file_location!

  config.before type: :job do
    config.include ActiveJob::TestHelper
  end

  config.before :suite do
    FactoryBot.find_definitions
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def described_module = described_class
