# frozen_string_literal: true

class Gateway::Telegram::WebhooksController < ApplicationController
  rescue_from StandardError do |exception|
    Rails.logger.error(exception)

    raise exception unless Rails.env.production?

    head :ok
  end

  before_action do
    next if input.chat_object.present?

    head :unprocessable_entity
  end

  def notify
    dispatch_command

    head :ok
  end

  private

    def dispatch_command
      service_result = TelegramForm::ProcessRequestService.call(
        telegram_form, input:
      )

      if service_result.success?
        reply_with(event_response(service_result.event, service_result.context))
      else
        reply_with(event_response(service_result.reason, {}))
      end
    end

    def event_response(event, context)
      # NOTE: dirty!
      return context.fetch(:preview) if event == :succeeded_preview

      context = if event == :created_upload
        { filename: context.fetch(:upload).filename }
      elsif event == :updated_to_course_provided_stage
        { assignments: telegram_form.course.assignments.pluck(:title).join("\n") }
      elsif event == :updated_to_created_stage
        { courses: Course.active.pluck(:title).join("\n") }
      else
        {}
      end

      I18n.with_locale(:ru) { t event, context }
    end

    def t(key, context = {})
      I18n.t(key, **context, scope: "controllers.gateway.telegram.webhooks.messages")
    end

    def telegram_form
      return @telegram_form if defined?(@telegram_form)

      @telegram_form = TelegramForm.incompleted.find_by(chat_identifier: input.chat_id)
    end

    def reply_with(message) = api_client.send_message(chat_id: input.chat_id, text: message)

    def input = @input ||= TelegramForm::ParseInputService.call(params).input

    def api_client
      @api_client ||= Telegram::Bot::Client.new(Rails.application.credentials.services.telegram_bot)
    end
end
