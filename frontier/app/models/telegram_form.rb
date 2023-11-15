# frozen_string_literal: true

# == Schema Information
#
# Table name: telegram_forms
#
#  id               :uuid             not null, primary key
#  stage            :string           default(NULL), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  assignment_id    :uuid
#  course_id        :uuid
#  submission_id    :uuid
#  telegram_chat_id :uuid             not null
#
# Indexes
#
#  index_telegram_forms_on_assignment_id     (assignment_id)
#  index_telegram_forms_on_course_id         (course_id)
#  index_telegram_forms_on_submission_id     (submission_id)
#  index_telegram_forms_on_telegram_chat_id  (telegram_chat_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignment_id => assignments.id)
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (submission_id => submissions.id)
#  fk_rails_...  (telegram_chat_id => telegram_chats.id)
#
class TelegramForm < ApplicationRecord
  extend Enumerize

  include AASM

  STAGES = %w[
    created
    telegram_chat_populated
    course_provided
    assignment_provided
    uploads_provided
  ].freeze

  aasm column: :stage, requires_lock: true, whiny_transitions: false do
    state :created, initial: true
    state :telegram_chat_populated
    state :course_provided
    state :assignment_provided
    state :uploads_provided

    event :telegram_chat_populated do
      transitions from: :created, to: :telegram_chat_populated
    end

    event :course_provided do
      transitions from: :telegram_chat_populated, to: :course_provided do
        guard { course.present? }
      end
    end

    event :assignment_provided do
      transitions from: :course_provided, to: :assignment_provided do
        guard { assignment.present? }
      end
    end

    event :uploads_provided do
      transitions from: :assignment_provided, to: :uploads_provided do
        guard { uploads.any? }
      end
    end
  end

  enumerize :stage, in: STAGES, predicates: true, scope: :shallow, default: "created"

  scope :completed, -> { where(stage: "uploads_provided") }
  scope :incompleted, -> { where.not(stage: "uploads_provided") }

  belongs_to :telegram_chat

  with_options optional: true do
    belongs_to :course
    belongs_to :assignment
    belongs_to :submission
  end

  with_options presence: true do
    validates :stage
    validates :course, if: :course_provided?
    validates :assignment, if: :assignment_provided?
    validates :submission, if: :uploads_provided?
  end

  def self.ransackable_attributes(*)
    %w[assignment_id course_id created_at id id_value stage submission_id telegram_chat_id updated_at]
  end
end
