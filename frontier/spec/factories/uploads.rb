# frozen_string_literal: true

# == Schema Information
#
# Table name: uploads
#
#  id              :uuid             not null, primary key
#  filename        :string           not null
#  metadata        :jsonb            not null
#  uploadable_type :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  uploadable_id   :uuid             not null
#
# Indexes
#
#  index_uploads_on_uploadable  (uploadable_type,uploadable_id)
#
FactoryBot.define do
  factory :upload do
    for_submission

    filename { Faker::File.file_name }
    metadata { {} }
    source { %w[telegram].sample }

    trait :for_submission do
      uploadable factory: %i[submission_files_group]
    end
  end
end
