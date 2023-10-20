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
RSpec.describe Upload do
  describe "associations" do
    it { is_expected.to belong_to(:uploadable) }
  end

  describe "validations" do
    it { is_expected.to validate_length_of(:filename).is_at_least(3).is_at_most(128) }
    it { is_expected.to validate_presence_of(:filename) }
  end
end
