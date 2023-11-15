# frozen_string_literal: true

class TelegramForm::ProcessRequestService < ApplicationService
  subject :telegram_form

  context :telegram_chat
  context :input

  result_on_success :event, :context
  result_on_failure :reason

  def call
    return failure! reason: :invalid_command if !input.command_type.start? && !telegram_chat

    "TelegramForm::ProcessRequestService::#{input.command_type.upcase_first}Service".constantize.call(
      telegram_form, telegram_chat:, input:
    )
  end
end
