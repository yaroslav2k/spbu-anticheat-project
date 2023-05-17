# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id         :uuid             not null, primary key
#  course_id  :uuid
#  title      :string           not null
#  identifier :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Assignment < ApplicationRecord
  TITLE_MIN_LENGTH = 8
  TITLE_MAX_LENGTH = 80

  IDENTIFIER_LENGTH = 6

  belongs_to :course

  has_many :submissions, dependent: :destroy

  validates :title, presence: true, length: { in: TITLE_MIN_LENGTH..TITLE_MAX_LENGTH }
  validates :identifier, uniqueness: true

  scope :active, -> { joins(:course).where(course: { year: Date.current.year }) }
  scope :for, ->(user) { joins(:course).where(course: { user: user }) }

  before_validation do
    self.identifier = generate_identifier
  end

  def has_report?
    submissions.completed.any?
  end

  def storage_key
    "courses/#{course.id}/assignments/#{storage_identifier}"
  end

  def report_storage_key
    "courses/#{course.id}/assignments/#{storage_identifier}/clusterisation_report.json"
  end

  def storage_identifier
    id
  end

  private

    def generate_identifier
      IDENTIFIER_LENGTH.times.map { rand(10) }.join
    end
end
