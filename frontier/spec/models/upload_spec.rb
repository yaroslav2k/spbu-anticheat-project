# frozen_string_literal: true

# == Schema Information
#
# Table name: uploads
#
#  id              :uuid             not null, primary key
#  filename        :string           not null
#  metadata        :jsonb            not null
#  uploadable_type :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  uploadable_id   :uuid             not null
#
# Indexes
#
#  index_uploads_on_uploadable  (uploadable_type,uploadable_id)
#
RSpec.describe Upload do
  describe "constants" do
    describe "AVAILABLE_SOURCES" do
      it { expect(described_class::AVAILABLE_SOURCES).to eq(%w[telegram]) }
      it { expect(described_class::AVAILABLE_SOURCES).to be_frozen }
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:uploadable) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:source) }
    it { is_expected.to validate_length_of(:filename).is_at_least(3).is_at_most(128) }
    it { is_expected.to validate_presence_of(:filename) }
  end

  describe "instance methods" do
    describe "#source_url" do
      subject(:upload) { create(:upload) }

      its(:source_url) { is_expected.to eq("https://127.0.0.1/storage/test/uploads/#{upload.id}") }
    end
  end
end
