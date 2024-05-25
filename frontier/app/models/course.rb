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
#  index_courses_on_title_and_year_and_semester  (title,year,semester) UNIQUE
#  index_courses_on_user_id                      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Course < ApplicationRecord
  TITLE_MIN_LENGTH = 3
  TITLE_MAX_LENGTH = 40

  belongs_to :user

  has_many :assignments, dependent: :destroy
  has_many :submissions, through: :assignments

  has_many :groups, dependent: :destroy

  scope :for, ->(user) { where(user:) }
  scope :active, -> { where(year: Date.current.year) }

  normalizes :semester, with: ->(value) { value.strip.downcase }

  validates :title, presence: true, length: { in: TITLE_MIN_LENGTH..TITLE_MAX_LENGTH }
  validates :title, uniqueness: { case_sensitive: false, scope: %i[year semester] }
  validates :semester, inclusion: { in: %w[spring fall] }
  validates :year, numericality: { only_integer: true }

  before_validation do
    self.year ||= Date.current.year
  end

  def self.ransackable_attributes(*)
    %w[created_at id id_value semester title updated_at user_id year group_id]
  end

  def self.ransackable_associations(*)
    %w[assignments user groups]
  end
end
