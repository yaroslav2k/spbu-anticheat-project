# frozen_string_literal: true

class Gateway::Telegram::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def notify
    message = params.dig(:message, :text).presence

    if message == "/start"
      reply_with("Hello there")
    elsif message.starts_with?("/send")
      items = message.split

      reply_with("repository URL: #{items[1]}")
    else
      reply_with("Unknown command")
    end

    head :ok
  end

  private

    def reply_with(message)
      api_client.send_message(
        chat_id: chat_id_param,
        text: message
      )
    end

    def chat_id_param
      params.dig(:message, :chat, :id).to_s
    end

    def api_client
      @api_client ||= Telegram::Bot::Client.new(Rails.application.credentials.services.telegram_bot)
    end
end
