# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id                :uuid             not null, primary key
#  options           :jsonb            not null
#  submissions_count :integer
#  title             :citext           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  course_id         :uuid             not null
#
# Indexes
#
#  index_assignments_on_course_id            (course_id)
#  index_assignments_on_course_id_and_title  (course_id,title) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
class Assignment < ApplicationRecord
  TITLE_MIN_LENGTH = 4
  TITLE_MAX_LENGTH = 80

  belongs_to :course

  has_many :submissions, dependent: :destroy

  normalizes :title, with: ->(value) { value.strip }

  validates :title, presence: true, length: { in: TITLE_MIN_LENGTH..TITLE_MAX_LENGTH }
  validates :title, uniqueness: { case_sensitive: false, scope: %i[course_id] }

  scope :for, ->(user) { joins(:course).where(course: { user: }) }
  scope :active, -> { joins(:course).where(course: { year: Date.current.year }) }

  default_scope { order(created_at: :desc) }

  ALGORITHM_OPTIONS = DetectionMethod::ALL.to_h { [_1.name, %i[jsonb]] }.freeze

  jsonb_accessor :options,
    nicad: [:jsonb],
    algorithm: [:string, { default: "nicad" }],
    **Assignment::ALGORITHM_OPTIONS

  after_initialize :initialize_algorithm_parameters

  def self.ransackable_attributes(*)
    %w[course_id created_at id id_value options submissions_count title updated_at]
  end

  def self.ransackable_associations(*)
    %w[course submissions]
  end

  def has_report?
    submissions.completed.any?
  end

  # FIXME: Extract persistence-related logic to separate concern/layer.

  def storage_key
    "courses/#{course.id}/assignments/#{storage_identifier}"
  end

  def report_storage_key
    nicad_report_storage_key
  end

  def nicad_report_storage_key
    "courses/#{course.id}/assignments/#{storage_identifier}/reports/nicad.json"
  end

  def report_url
    Storage::PRIMARY.public_url(report_storage_key)
  end

  def storage_identifier
    id
  end

  private

  def initialize_algorithm_parameters
    self.algorithm = DetectionMethod::DEFAULT.name

    DetectionMethod::ALL.each do |detection_method|
      public_send(
        :"#{detection_method.name}=",
        detection_method.parameters.to_h { [_1[:name], _1[:default]] }
      )
    end
  end
end
