# frozen_string_literal: true

FactoryBot.define do
  factory :assignment do
    title { Faker::Lorem.characters(number: 10) }

    association :course
  end
end
