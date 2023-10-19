# frozen_string_literal: true

FactoryBot.define do
  factory :course do
    semester { %w[fall spring].sample }
    title { Faker::Lorem.characters(number: 10) }
    year { (2000..2023).to_a.sample }

    association :user
  end
end
