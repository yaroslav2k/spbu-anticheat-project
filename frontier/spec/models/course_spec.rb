# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id         :uuid             not null, primary key
#  semester   :string           not null
#  title      :string           not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_courses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
RSpec.describe Course do
  describe "constants" do
    describe "TITLE_MIN_LENGTH" do
      it { expect(described_class::TITLE_MIN_LENGTH).to eq(3) }
    end

    describe "TITLE_MAX_LENGTH" do
      it { expect(described_class::TITLE_MAX_LENGTH).to eq(40) }
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:assignments).dependent(:destroy) }
  end

  describe "scopes" do
    describe ".for" do
      let(:user) { create(:user) }

      it { expect(described_class.for(user).to_sql).to eq(described_class.where(user:).to_sql) }
    end

    describe ".active" do
      it { expect(described_class.active.to_sql).to eq(described_class.where(year: Date.current.year).to_sql) }
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_least(3).is_at_most(40) }
    it { is_expected.to validate_inclusion_of(:semester).in_array(%w[spring fall]) }
    it { is_expected.to validate_numericality_of(:year).only_integer }
  end
end
