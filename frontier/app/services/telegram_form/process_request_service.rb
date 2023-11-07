# frozen_string_literal: true

class TelegramForm::ProcessRequestService < ApplicationService
  subject :telegram_form

  context :input

  result_on_success :event, :context
  result_on_failure :reason

  def call
    "TelegramForm::ProcessRequestService::#{input.command_type.upcase_first}Service".constantize.call(
      telegram_form, telegram_chat:, input:
    )
  end

  private

    def telegram_chat
      @telegram_chat ||= TelegramChat.find_or_create_by!(external_identifier: input.chat_id)
    end
end
