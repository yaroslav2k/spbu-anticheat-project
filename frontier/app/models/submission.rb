# frozen_string_literal: true

# == Schema Information
#
# Table name: submissions
#
#  id         :uuid             not null, primary key
#  task_id    :uuid
#  url        :string           not null
#  branch     :string           default("master"), not null
#  author     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Submission < ApplicationRecord
  belongs_to :task
end
