# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id         :uuid             not null, primary key
#  user_id    :uuid
#  title      :string           not null
#  identifier :string           not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Assignment < ApplicationRecord
  TITLE_MIN_LENGTH = 8
  TITLE_MAX_LENGTH = 80

  IDENTIFIER_LENGTH = 6

  belongs_to :user

  validates :title, presence: true, length: { in: TITLE_MIN_LENGTH..TITLE_MAX_LENGTH }
  validates :year, numericality: { only_integer: true }
  validates :identifier, uniqueness: true

  scope :active, -> { where(year: Date.current.year) }
  scope :for, ->(user) { where(user: user) }

  before_validation do
    self.year ||= Date.current.year
    self.identifier = generate_identifier
  end

  def storage_key
    "submissions/#{storage_identifier}"
  end

  def report_storage_key
    "submissions/#{storage_identifier}/clusterisation_report.json"
  end

  def storage_identifier
    id
  end

  private

    def generate_identifier
      IDENTIFIER_LENGTH.times.map { rand(10) }.join
    end
end
