# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id                :uuid             not null, primary key
#  identifier        :string           not null
#  options           :jsonb            not null
#  submissions_count :integer
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  course_id         :uuid             not null
#
# Indexes
#
#  index_assignments_on_course_id   (course_id)
#  index_assignments_on_identifier  (identifier) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
FactoryBot.define do
  factory :assignment do
    title { Faker::Lorem.characters(number: 10) }

    association :course
  end
end
