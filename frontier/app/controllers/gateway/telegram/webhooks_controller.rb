# frozen_string_literal: true

class Gateway::Telegram::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def notify
    message = params.dig(:message, :text).presence

    if message == "/start"
      reply_with("Hello there")
    elsif message.starts_with?("/send")
      items = message.split

      if repository_url_valid?(items[1])
        Tasks::CreateJob.perform_later(items[1], items[2].presence)
        reply_with("Задание успешно добавлено")
      else
        reply_with("Некорректная ссылка на репозиторий")
      end
    else
      reply_with("Неизвестная команда")
    end

    head :ok
  end

  private

    def repository_url_valid?(repository_url)
      Tasks::VerifyURLService.call(repository_url).success?
    end

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
