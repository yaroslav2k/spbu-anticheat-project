# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id         :uuid             not null, primary key
#  user_id    :uuid
#  title      :string           not null
#  semester   :string           not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Course < ApplicationRecord
  TITLE_MIN_LENGTH = 3
  TITLE_MAX_LENGTH = 40

  belongs_to :user

  has_many :assignments, dependent: :destroy

  scope :for, ->(user) { where(user: user) }

  validates :title, presence: true, length: { in: TITLE_MIN_LENGTH..TITLE_MAX_LENGTH }
  validates :semester, inclusion: { in: %w[spring fall] }
  validates :year, numericality: { only_integer: true }

  before_validation do
    self.year ||= Date.current.year
  end

  scope :active, -> { where(year: Date.current.year) }
end
