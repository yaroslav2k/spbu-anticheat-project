# frozen_string_literal: true

class TelegramForm::ProcessRequestService::ResetService < TelegramForm::ProcessRequestService::ApplicationService
  def call
    return failure! reason: :unable_to_process_record unless telegram_form

    tx_result = ApplicationRecord.transaction do
      telegram_chat.update!(last_submitted_course: nil)
      telegram_form.update!(stage: :telegram_chat_populated, course: nil)
    end

    if tx_result
      success! event: :telegram_chat_group_provided
    else
      failure! reason: :unable_to_process_record
    end
  end
end
