# frozen_string_literal: true

FactoryBot.define do
  factory :telegram_chat do
    external_identifier { Faker::Internet.uuid }
    username { Faker::Name.name }

    trait :with_name do
      name { Faker::Name.name }
    end

    trait :with_group do
      group { "group-#{Faker::Number.positive.to_i}" }
    end

    trait :with_status_name_provided do
      status { "name_provided" }

      with_name
    end

    trait :with_status_group_provided do
      status { "group_provided" }

      with_name
      with_group
    end
  end
end
