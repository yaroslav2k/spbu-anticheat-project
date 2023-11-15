# frozen_string_literal: true

class TelegramForm::ProcessRequestService::ApplicationService < ApplicationService
  subject :telegram_form

  context :telegram_chat
  context :input

  result_on_success :event, :context
  result_on_failure :reason
end
