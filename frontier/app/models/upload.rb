# frozen_string_literal: true

# == Schema Information
#
# Table name: uploads
#
#  id              :bigint           not null, primary key
#  filename        :string           not null
#  metadata        :jsonb            not null
#  uploadable_type :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  uploadable_id   :bigint           not null
#
# Indexes
#
#  index_uploads_on_uploadable  (uploadable_type,uploadable_id)
#
class Upload < ApplicationRecord
  belongs_to :uploadable, polymorphic: true

  validates :filename, presence: true
  validates :filename, length: { in: (3..128) }

  jsonb_accessor :metadata,
    bytesize: :integer,
    mime_type: :string,
    source: :string,
    external_id: :string,
    external_unique_id: :string

  def storage_key
    "uploads/#{filename}"
  end
end
