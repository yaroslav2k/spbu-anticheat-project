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
class Assignment < ApplicationRecord
  TITLE_MIN_LENGTH = 4
  TITLE_MAX_LENGTH = 80

  IDENTIFIER_ALPHABET = [*"0".."9", *"a".."z", *"A".."Z"].freeze
  IDENTIFIER_LENGTH = 6

  belongs_to :course

  has_many :submissions, dependent: :destroy

  validates :title, presence: true, length: { in: TITLE_MIN_LENGTH..TITLE_MAX_LENGTH }
  validates :identifier, uniqueness: true
  validates :ngram_size, numericality: { only_integer: true, greater_than_or_equal_to: 2 }
  validates :threshold, numericality: { in: (0..1) }

  scope :for, ->(user) { joins(:course).where(course: { user: }) }
  scope :active, -> { joins(:course).where(course: { year: Date.current.year }) }

  jsonb_accessor :options,
    ngram_size: [:integer, { default: 2 }],
    threshold: [:float, { default: 0.5 }]

  after_initialize do
    self.identifier ||= generate_identifier
    self.ngram_size ||= 2
    self.threshold ||= 0.5
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
      IDENTIFIER_ALPHABET.sample(IDENTIFIER_LENGTH).join
    end
end
