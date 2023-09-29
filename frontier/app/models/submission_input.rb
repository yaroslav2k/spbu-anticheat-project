# frozen_string_literal: true

class SubmissionInput
  include ActiveModel::Attributes
  include ActiveModel::Model
  include ActiveModel::Validations

  attribute :key

  validates :key, presence: true
end
