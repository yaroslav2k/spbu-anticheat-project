# frozen_string_literal: true

# == Schema Information
#
# Table name: telegram_forms
#
#  id              :bigint           not null, primary key
#  author          :string
#  chat_identifier :string
#  stage           :string           default("initial"), not null
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
  STAGES = %w[
    initial
    course_provided
    assignment_provided
    author_provided
    completed
  ].freeze

  extend Enumerize

  scope :incompleted, -> { where.not(stage: "completed") }

  enumerize :stage, in: STAGES, predicates: true, default: "initial"

  belongs_to :course, optional: true
  belongs_to :assignment, optional: true
  belongs_to :submission, optional: true

  validates :stage, presence: true

  with_options presence: true do
    validates :course, if: :course_provided?
    validates :assignment, if: :assignment_provided?
    validates :author, if: :author_provided?
    validates :submission, if: :completed?
  end
end
