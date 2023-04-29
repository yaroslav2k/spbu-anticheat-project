# frozen_string_literal: true

namespace :telegram do
  namespace :bot do
    desc "Set webhook URL for telegram bot"
    task :set_webhook, [:url] => :environment do |_, args|
      api_token = (ENV["API_TOKEN"].presence || raise("Missing API_TOKEN environment variable"))

      response = HTTParty.post(
        "https://api.telegram.org/bot#{api_token}/setWebhook?url=#{args[:url]}"
      )

      puts response.body
    end

    desc "Remove webhook URL for telegram bot"
    task remove_webhook: :environment do
      api_token = (ENV["API_TOKEN"].presence || raise("Missing API_TOKEN environment variable"))

      response = HTTParty.post(
        "https://api.telegram.org/bot#{api_token}/setWebhook?url="
      )

      puts response.body
    end
  end
end
