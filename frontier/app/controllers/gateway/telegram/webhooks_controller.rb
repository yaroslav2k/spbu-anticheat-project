# frozen_string_literal: true

class Gateway::Telegram::WebhooksController < ApplicationController
  MESSAGES_MAPPING = {
    initial: "Пожалуйста, веберите курс",
    course_provided: "Пожалуйста, веберите задание",
    assignment_provided: "Введите ФИО и группу",
    author_provided: "Введите задание (одним файлом)",
    completed: "Принято"
  }.freeze

  rescue_from StandardError do |exception|
    Rails.logger.error(exception)

    head :ok
  end

  # rubocop:disable Metrics/PerceivedComplexity, Metrics/MethodLength
  def notify
    telegram_form = TelegramForm.find_or_create_by!(chat_identifier: chat_id_param)

    case telegram_form.stage.to_sym
    when :initial
      course = Course.find_by(title: message_param)
      if course && telegram_form.update(stage: "course_provided", course: course)
        reply_with(MESSAGES_MAPPING.fetch(:course_provided))
      else
        reply_with(MESSAGES_MAPPING.fetch(:initial))
      end
    when :course_provided
      assignment = Assignment.find_by(identifier: message_param)
      if assignment && telegram_form.update(stage: "assignment_provided", assignment: assignment)
        reply_with(MESSAGES_MAPPING.fetch(:assignment_provided))
      else
        reply_with("error")
      end
    when :assignment_provided
      if telegram_form.update(stage: "author_provided", author: message_param)
        reply_with(MESSAGES_MAPPING.fetch(:author_provided))
      else
        reply_with("error")
      end
    when :author_provided
      submission = create_submission!(telegram_form)

      if telegram_form.update(stage: "completed", submission: submission)
        reply_with(MESSAGES_MAPPING.fetch(:completed))
      else
        reply_with("error, try later")
      end

      Assignment::CreateJob.perform_later(submission)
    else
      reply_with("Unexpected state #{telegram_form.stage.to_sym}")
    end

    head :ok
  end
  # rubocop:enable Metrics/PerceivedComplexity, Metrics/MethodLength

  private

    def create_submission!(telegram_form)
      Submission::File.create!(
        assignment: telegram_form.assignment,
        author: telegram_form.author,
        external_id: params.dig(:message, :document, :file_id),
        external_unique_id: params.dig(:message, :document, :file_unique_id),
        filename: params.dig(:message, :document, :file_name),
        mime_type: params.dig(:message, :document, :mime_type)
      )
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

    def message_param
      @message_param ||= params.dig(:message, :text)
    end

    def api_client
      @api_client ||= Telegram::Bot::Client.new(Rails.application.credentials.services.telegram_bot)
    end
end
