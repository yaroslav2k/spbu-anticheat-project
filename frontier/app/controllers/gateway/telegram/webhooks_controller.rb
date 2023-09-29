# frozen_string_literal: true

class Gateway::Telegram::WebhooksController < ApplicationController
  WELCOME_MESSAGE = <<~TXT
    Отправьте решение задачи сообщением в одном из следующих форматов:

    1) Ссылка на git-репозиторий (GitHub)

    `/send <assignment-id> git-url=<github-url> identity="" [<branch>=master]`

    Пример:

    `/send 133713 git-url=https://github.com/torvalds/linux branch=homework-2 identity="Имя Фамиилия" `

    2) Файл с решением

    `/send <assignment-id> <identity>`

    где `identity` -- Ваше ФИО. В это же сообщение приложите файл.
  TXT

  rescue_from StandardError do |exception|
    Rails.logger.error(exception)

    head :ok
  end

  def notify
    input = Submission::ParseInputService.call(params)

    Rails.logger.info("Command type: #{input.command_type}")

    if input.command_type.start?
      reply_with(WELCOME_MESSAGE)
    elsif input.command_type.send?
      unless input.valid?
        reply_with("Unexpected error")

        return head :ok
      end

      unless (assignment = load_assignment(input.assignment_id))
        reply_with("Некорректный номер задания")

        return head :ok
      end

      submission = Submission::BuildService.call(input)
      submission.assignment = assignment

      submission.save!

      Assignment::CreateJob.perform_later(submission)

      reply_with("Submission was sent")
    else
      reply_with("Undefined behaviour, please check available commands")
    end
  end

  private

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

    def api_client
      @api_client ||= Telegram::Bot::Client.new(Rails.application.credentials.services.telegram_bot)
    end
end
