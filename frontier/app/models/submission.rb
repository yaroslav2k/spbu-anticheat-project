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

  normalizes :author_group, with: ->(value) { value.strip }
  normalizes :author_name, with: ->(value) { value.strip }

  alias_attribute :sent_at, :created_at

  enumerize :status, in: %i[created completed failed], default: "created", scope: :shallow, predicates: true

  has_one :telegram_form, dependent: :destroy

  def download_url = nil

  scope :git, -> { where(type: "Submission::Git") }
  scope :files_group, -> { where(type: "Submission::FilesGroup") }

  def self.ransackable_attributes(*)
    %w[assignment_id author_group author_name created_at data id id_value sent_at status type updated_at]
  end

  def self.ransackable_associations(*)
    %w[assignment telegram_form]
  end

  def of_type
    self.class.name.demodulize.underscore.inquiry
  end

  def storage_key
    "courses/#{assignment.course.id}/assignments/#{assignment.id}/submissions/#{storage_identifier}/manifest.json"
  end

  def storage_identifier = id

  class Git < Submission
    validates :branch, presence: true
    validates :url, url: { domain: "github.com", perform_request: true }, git_remote: { branch: ->(record) { record.branch } }

    jsonb_accessor :data,
      url: :string,
      branch: [:string, { default: "main" }]

    def source_label = "(git)"

    def source_url = url

    # FIXME: Move to presentation layer.
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

    def to_s
      "File (#{author_name})"
    end
  end
end
