# frozen_string_literal: true

# == Schema Information
#
# Table name: submissions
#
#  id            :uuid             not null, primary key
#  assignment_id :uuid
#  url           :string           not null
#  branch        :string           default("master"), not null
#  author        :string           not null
#  status        :string           default("created"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Submission < ApplicationRecord
  extend Enumerize

  belongs_to :assignment, counter_cache: true

  scope :recent, -> { order(created_at: :desc) }
  scope :for, ->(user) { includes(:assignment).where(assignment: Assignment.for(user)) }

  alias_attribute :sent_at, :created_at

  enumerize :status, in: %i[created completed failed], scope: :shallow, predicates: true

  def to_s
    "#{url} (#{branch}) — #{author}"
  end

  def storage_key
    "courses/#{assignment.course.id}/assignments/#{assignment.id}/submissions/#{storage_identifier}"
  end

  def storage_identifier
    id
  end
end
