# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id         :uuid             not null, primary key
#  user_id    :uuid
#  status     :string           default("created"), not null
#  identifier :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Task < ApplicationRecord
  belongs_to :user
end
