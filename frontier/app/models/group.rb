# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id         :uuid             not null, primary key
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :uuid             not null
#
# Indexes
#
#  index_groups_on_course_id  (course_id)
#  index_groups_on_title      (title) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
class Group < ApplicationRecord
  normalizes :title, with: ->(value) { value.strip }

  validates :title, presence: true, uniqueness: true

  belongs_to :course

  def self.for(user)
    where(course: user.courses)
  end

  def self.ransackable_associations(*)
    %w[course]
  end

  def self.ransackable_attributes(*)
    %w[course_id created_at id id_value title updated_at]
  end
end
