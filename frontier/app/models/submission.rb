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
class Submission < ApplicationRecord
  extend Enumerize

  belongs_to :assignment, counter_cache: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for, ->(user) { includes(:assignment).where(assignment: Assignment.for(user)) }

  alias_attribute :sent_at, :created_at

  enumerize :status, in: %i[created completed failed], scope: :shallow, predicates: true

  has_one :telegram_form, dependent: :destroy

  def download_url = nil

  scope :git, -> { where(type: "Submission::Git") }
  scope :files_group, -> { where(type: "Submission::FilesGroup") }

  class Git < Submission
    validates :url, presence: true
    validates :branch, presence: true

    jsonb_accessor :data,
      url: :string,
      branch: [:string, { default: "main" }]

    def storage_key
      "courses/#{assignment.course.id}/assignments/#{assignment.id}/submissions/#{storage_identifier}"
    end

    def source_label = "(git)"

    def source_url = url

    def to_s
      "#{url} (#{branch}) — #{author_name} (#{author_group})"
    end
  end

  class FilesGroup < Submission
    has_many :uploads, as: :uploadable, dependent: :destroy

    def source_label = "(file)"

    def source_url
      Storage::PRIMARY.public_url(storage_key)
    end

    def storage_key
      "uploads/#{storage_identifier}"
    end

    def to_s
      "File (#{author_name})"
    end
  end
end
