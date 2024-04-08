# frozen_string_literal: true

namespace :telegram do
  namespace :bot do
    desc "Set webhook URL for telegram bot"
    task :set_webhook, [:url] => :environment do |_, args|
      api_token = Frontier.config.telegram_bot_config.api_token

      response = HTTParty.post(
        "https://api.telegram.org/bot#{api_token}/setWebhook?url=#{args[:url]}/gateway/telegram/webhooks/notify"
      )

      if response.success?
        exit 0
      else
        p response.parsed_response

        exit 1
      end
    end

    desc "Remove webhook URL for telegram bot"
    task remove_webhook: :environment do
      api_token = ENV["API_TOKEN"].presence || raise("Missing API_TOKEN environment variable")

      response = HTTParty.post(
        "https://api.telegram.org/bot#{api_token}/setWebhook?url="
      )

      if response.success?
        exit 0
      else
        p response.parsed_response

        exit 1
      end
    end
  end
end
