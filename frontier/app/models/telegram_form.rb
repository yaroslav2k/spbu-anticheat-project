# frozen_string_literal: true

# == Schema Information
#
# Table name: telegram_forms
#
#  id              :uuid             not null, primary key
#  author_group    :string
#  author_name     :string
#  chat_identifier :string
#  stage           :string           default(NULL), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  assignment_id   :uuid
#  course_id       :uuid
#  submission_id   :uuid
#
# Indexes
#
#  index_telegram_forms_on_assignment_id    (assignment_id)
#  index_telegram_forms_on_chat_identifier  (chat_identifier)
#  index_telegram_forms_on_course_id        (course_id)
#  index_telegram_forms_on_submission_id    (submission_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignment_id => assignments.id)
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (submission_id => submissions.id)
#
class TelegramForm < ApplicationRecord
  extend Enumerize

  include AASM

  STAGES = %w[
    created
    course_provided
    assignment_provided
    author_name_provided
    author_group_provided
    uploads_provided
  ].freeze

  aasm column: :stage, requires_lock: true, whiny_transitions: false do
    state :created, initial: true
    state :course_provided
    state :assignment_provided
    state :author_name_provided
    state :author_group_provided
    state :uploads_provided

    event :course_provided do
      transitions from: :created, to: :course_provided do
        guard { course.present? }
      end
    end

    event :assignment_provided do
      transitions from: :course_provided, to: :assignment_provided do
        guard { assignment.present? }
      end
    end

    event :author_name_provided do
      transitions from: :assignment_provided, to: :author_name_provided do
        guard { author_name.present? }
      end
    end

    event :author_group_provided do
      transitions from: :author_name_provided, to: :author_group_provided do
        guard { author_group.present? }
      end
    end

    event :uploads_provided do
      transitions from: :author_group_provided, to: :uploads_provided do
        guard { uploads.any? }
      end
    end
  end

  enumerize :stage, in: STAGES, predicates: true, scope: :shallow, default: "created"

  scope :incompleted, -> { where.not(stage: "uploads_provided") }

  belongs_to :course, optional: true
  belongs_to :assignment, optional: true
  belongs_to :submission, optional: true

  validates :stage, presence: true

  with_options presence: true do
    validates :course, if: :course_provided?
    validates :assignment, if: :assignment_provided?
    validates :author_name, if: :author_name_provided?
    validates :author_group, if: :author_group_provided?
    validates :submission, if: :uploads_provided?
  end
end
