# frozen_string_literal: true

class TelegramForm::ProcessRequestService::ApplicationService < ApplicationService
  subject :telegram_form

  context :input
  context :telegram_chat

  result_on_success :event, :context
  result_on_failure :reason
end
