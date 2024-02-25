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
FactoryBot.define do
  factory :telegram_form do
    submission factory: %i[submission_files_group]

    traits_for_enum :stage, TelegramForm::STAGES

    telegram_chat
  end
end
