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
  belongs_to :assignment

  scope :recent, -> { order(created_at: :desc) }
  scope :for, ->(user) { where(assignment: { user: user }) }

  alias_attribute :sent_at, :created_at

  def to_s
    "#{url} (#{branch}) — #{author}"
  end
end
