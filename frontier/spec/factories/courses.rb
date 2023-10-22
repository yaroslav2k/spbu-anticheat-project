# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id         :uuid             not null, primary key
#  semester   :string           not null
#  title      :citext           not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_courses_on_title    (title) UNIQUE
#  index_courses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :course do
    semester { %w[fall spring].sample }
    title { Faker::Lorem.characters(number: 10) }
    year { (2000..2023).to_a.sample }

    trait :active do
      year { Date.current.year }
    end

    user
  end
end
