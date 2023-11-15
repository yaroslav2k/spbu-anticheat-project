# frozen_string_literal: true

class TelegramForm::ProcessRequestService::SubmitService < TelegramForm::ProcessRequestService::ApplicationService
  def call
    # telegram_form = telegram_chat.telegram_forms.incompleted.sole
    # return failure! reason: :unable_to_process_record unless telegram_form
    tx_result = ApplicationRecord.transaction do
      telegram_form.update!(stage: :uploads_provided)
      telegram_chat.update!(last_submitted_course: telegram_form.course)
    end

    if tx_result
      Assignment::CreateJob.perform_later(telegram_form.submission)

      assignments = Assignment
                    .joins(submissions: { telegram_form: :telegram_chat })
                    .where(telegram_chat: { external_identifier: input.chat_id })
                    .where(telegram_form: { course_id: telegram_form.course_id })
                    .order(:created_at)

      success! event: :updated_to_uploads_provided_stage, context: { assignments: }
    else
      failure! reason: :unable_to_process_record
    end
  end
end
