# frozen_string_literal: true

FactoryBot.define do
  factory :submission do
    author { Faker::Name.name }

    association :assignment

    trait :files_group do
      type { "Submission::FilesGroup" }
    end
  end
end
