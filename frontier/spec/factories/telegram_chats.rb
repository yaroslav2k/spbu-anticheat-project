# frozen_string_literal: true

# == Schema Information
#
# Table name: telegram_chats
#
#  id                       :uuid             not null, primary key
#  external_identifier      :string           not null
#  group                    :string
#  name                     :string
#  status                   :string           default("created"), not null
#  username                 :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  last_submitted_course_id :uuid
#
# Indexes
#
#  index_telegram_chats_on_external_identifier       (external_identifier) UNIQUE
#  index_telegram_chats_on_last_submitted_course_id  (last_submitted_course_id)
#
# Foreign Keys
#
#  fk_rails_...  (last_submitted_course_id => courses.id)
#
FactoryBot.define do
  factory :telegram_chat do
    external_identifier { Faker::Internet.uuid }
    username { Faker::Name.name }

    trait :with_name do
      name { Faker::Name.name }
    end

    trait :with_group do
      group { Course.pluck(:group).sample }
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
