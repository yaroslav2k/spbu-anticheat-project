# frozen_string_literal: true

class TelegramBotConfig < ApplicationConfig
  config_name :telegram_bot

  attr_config :api_token

  required :api_token
end
