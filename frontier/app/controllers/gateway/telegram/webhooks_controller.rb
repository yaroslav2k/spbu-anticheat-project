# frozen_string_literal: true

class Gateway::Telegram::WebhooksController < ApplicationController
  MESSAGES_MAPPING = {
    initial: "Пожалуйста, введите название доступного курса:",
    course_provided: "Пожалуйста, веберите задание",
    assignment_provided: "Введите свое ФИО",
    author_name_provided: "Введите номер свой группы",
    author_group_provided: "Приложите решение одним или несколькими файлами. Затем введите команду `/submit`",
    completed: "Файл принят",
    form_submitted: "Решение принято"
  }.freeze

  before_action do
    next if chat_object.present?

    head :unprocessable_entity
  end

  # rescue_from StandardError do |exception|
  #   Rails.logger.error(exception)

  #   head :ok
  # end

  def notify
    if message_param == "/submit"
      handle_submit

      head :ok
      return
    end

    telegram_form = TelegramForm.incompleted.find_or_initialize_by(
      chat_identifier: chat_id_param
    )

    if telegram_form.new_record?
      telegram_form.save!
      reply_with(response_message(:initial))

      head :ok
    else
      send(:"process_state_#{telegram_form.stage}", telegram_form)
    end

    head :ok
  end

  private

    def handle_submit
      telegram_form = TelegramForm.incompleted.find_or_initialize_by(
        chat_identifier: chat_id_param
      )

      if telegram_form&.update(stage: :completed)
        reply_with(response_message(:form_submitted))
        Assignment::CreateJob.perform_later(telegram_form.submission)
      else
        reply_with("Не удалось сохранить отправку")
      end
    end

    def process_state_initial(telegram_form)
      course = Course.find_by(title: message_param)
      if telegram_form.update(stage: "course_provided", course: course)
        reply_with(response_message(:course_provided))
      else
        reply_with("Некорректное название курса")
      end
    end

    def process_state_course_provided(telegram_form)
      assignment = Assignment.find_by(identifier: message_param)

      if assignment && telegram_form.update(stage: "assignment_provided", assignment: assignment)
        reply_with(response_message(:assignment_provided))
      else
        reply_with("Некорректный идентификатор задания")
      end
    end

    def process_state_assignment_provided(telegram_form)
      if telegram_form.update(stage: "author_name_provided", author_name: message_param)
        reply_with(response_message(:author_name_provided))
      else
        reply_with("Не удалось сохранить имя автора")
      end
    end

    def process_state_author_name_provided(telegram_form)
      if telegram_form.update(stage: "author_group_provided", author_group: message_param)
        reply_with(response_message(:author_group_provided))
      else
        reply_with("Не удалось сохранить имя автора")
      end
    end

    def process_state_author_group_provided(telegram_form)
      submission = create_submission!(telegram_form)
      _upload = create_upload!(submission)

      if telegram_form.update(submission: submission)
        reply_with(response_message(:completed))
      else
        reply_with("error, try later")
      end
    end

    def response_message(telegram_form_stage)
      case telegram_form_stage.to_sym
      when :initial
        "#{MESSAGES_MAPPING.fetch(:initial)}\n\n#{Course.active.pluck(:title).join("\n")}"
      when :completed
        MESSAGES_MAPPING.fetch(:completed) + " (#{params.dig(:message, :document, :file_name)})"
      else
        MESSAGES_MAPPING.fetch(telegram_form_stage)
      end
    end

    def create_submission!(telegram_form)
      telegram_form.assignment.submissions.files_group.first_or_create!(
        author_name: telegram_form.author_name,
        author_group: telegram_form.author_group
      )
    end

    def create_upload!(submission)
      submission.uploads.create!(
        external_id: params.dig(:message, :document, :file_id),
        external_unique_id: params.dig(:message, :document, :file_unique_id),
        filename: params.dig(:message, :document, :file_name),
        mime_type: params.dig(:message, :document, :mime_type),
        source: :telegram
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
      @chat_id_param ||= chat_object[:id]
    end

    def message_param
      @message_param ||= params.dig(:message, :text)
    end

    def api_client
      @api_client ||= Telegram::Bot::Client.new(Rails.application.credentials.services.telegram_bot)
    end
end
