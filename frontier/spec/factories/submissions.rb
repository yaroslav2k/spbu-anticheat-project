# frozen_string_literal: true

# == Schema Information
#
# Table name: submissions
#
#  id            :uuid             not null, primary key
#  author_group  :string           not null
#  author_name   :string           not null
#  data          :jsonb            not null
#  status        :string           default("created"), not null
#  type          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  assignment_id :uuid
#
# Indexes
#
#  index_submissions_on_assignment_id  (assignment_id)
#
# Foreign Keys
#
#  fk_rails_...  (assignment_id => assignments.id)
#
FactoryBot.define do
  factory :submission do
    author_name { Faker::Name.name }
    author_group { "group-#{Faker::Number.positive.to_i}" }

    assignment
  end

  factory :submission_git, parent: :submission, class: "Submission::Git" do
    branch { %w[main master feature].sample }
    url { "https://github.com/agda" }
  end

  factory :submission_files_group, parent: :submission, class: "Submission::FilesGroup"
end
