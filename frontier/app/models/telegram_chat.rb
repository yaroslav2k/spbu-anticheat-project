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
class TelegramChat < ApplicationRecord
  extend Enumerize

  enumerize :status, in: %w[created name_provided group_provided], default: "created", predicates: true

  normalizes :group, with: ->(value) { value.strip }
  normalizes :name, with: ->(value) { value.strip }

  validate :validate_group_validity, if: :group

  validates :external_identifier, uniqueness: true

  with_options presence: true do
    validates :external_identifier
    validates :username
  end

  has_many :telegram_forms, dependent: :destroy

  belongs_to :last_submitted_course, class_name: "Course", optional: true

  def self.ransackable_attributes(*)
    %w[created_at external_identifier group id id_value last_submitted_course_id name status updated_at username]
  end

  def self.ransackable_associations(*)
    %w[last_submitted_course telegram_forms]
  end

  def completed?
    status.group_provided?
  end

  def latest_submitted_course
    telegram_forms.completed.order(updated_at: :desc).take&.course
  end

  private

    def validate_group_validity
      return if Course.exists?(group:)

      errors.add(:group, :does_not_exist)
    end
end
