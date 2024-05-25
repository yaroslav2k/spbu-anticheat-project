# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    course

    title { Faker::Lorem.word }
  end
end
