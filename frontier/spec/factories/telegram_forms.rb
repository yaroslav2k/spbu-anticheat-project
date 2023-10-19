# frozen_string_literal: true

FactoryBot.define do
  factory :telegram_form do
    traits_for_enum :stage, TelegramForm::STAGES
  end
end
