# frozen_string_literal: true

class Gateway::Telegram::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  WELCOME_MESSAGE = <<~TXT
    Welcome to SPbU-detector bot \u{1F440}

    Send submission in the following format:
    /send <github-url> [<branch>]
  TXT

  def notify
    message = params.dig(:message, :text).presence

    if message == "/start"
      reply_with(WELCOME_MESSAGE)
    elsif message.starts_with?("/send")
      items = message.split

    if repository_url_valid?(items[1])
        Assignment::CreateJob.perform_later(items[1], items[2].presence)
        reply_with("Submission was enqueued")
    else
        reply_with("Invalid GIT url")
    end
    else
      reply_with("Undefined behaviour, please check available commands")
    end

    head :ok
  end

  private

    def repository_url_valid?(repository_url)
      Assignment::VerifyURLService.call(repository_url).success?
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
