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

      unless (assignment = load_assignment(items[1]))
        reply_with("Invalid assignment ID")

        return head :ok
      end

      unless repository_url_valid?(items[2])
        reply_with("Invalid repository URL")

        return head :ok
      end

      unless Submission.create(assignment: assignment, author: author_name, url: items[2], branch: items[3])
        reply_with("Unknown error, please retry later")

        return head :ok
      end

      Assignment::CreateJob.perform_later(items[2], items[3].presence)
      reply_with("Submission was sent")
    else
      reply_with("Undefined behaviour, please check available commands")
    end

    head :ok
  end

  private

    def repository_url_valid?(repository_url)
      Assignment::VerifyURLService.call(repository_url).success?
    end

    def load_assignment(identifier)
      return nil if identifier.blank?

      Assignment.find_by(identifier: identifier)
    end

    def reply_with(message)
      api_client.send_message(
        chat_id: chat_id_param,
        text: message
      )
    end

    def chat_object
      @chat_object ||= params.dig(:message, :chat)
    end

    def chat_id_param
      @chat_id_param ||= chat_object[:id].to_s
    end

    def author_name
      @author_name ||= "#{chat_object[:first_name]} #{chat_object[:last_name]} (#{chat_object[:username]})"
    end

    def api_client
      @api_client ||= Telegram::Bot::Client.new(Rails.application.credentials.services.telegram_bot)
    end
end
