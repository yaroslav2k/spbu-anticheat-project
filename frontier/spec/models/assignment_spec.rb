# frozen_string_literal: true

# == Schema Information
#
# Table name: assignments
#
#  id                :uuid             not null, primary key
#  identifier        :string           not null
#  options           :jsonb            not null
#  submissions_count :integer
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  course_id         :uuid             not null
#
# Indexes
#
#  index_assignments_on_course_id   (course_id)
#  index_assignments_on_identifier  (identifier) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
RSpec.describe Assignment do
  describe "constants" do
    describe "TITLE_MIN_LENGTH" do
      it { expect(described_class::TITLE_MIN_LENGTH).to eq(4) }
    end

    describe "TITLE_MAX_LENGTH" do
      it { expect(described_class::TITLE_MAX_LENGTH).to eq(80) }
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:course) }
    it { is_expected.to have_many(:submissions).dependent(:destroy) }
  end

  describe "scopes" do
    describe ".for" do
      let(:user) { create(:user) }

      specify do
        expect(described_class.for(user).to_sql).to eq(
          described_class.joins(:course).where(course: { user: user }).to_sql
        )
      end
    end

    describe ".active" do
      specify do
        expect(described_class.active.to_sql).to eq(
          described_class.joins(:course).where(course: { year: Date.current.year }).to_sql
        )
      end
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_least(4).is_at_most(80) }
    it { is_expected.to validate_numericality_of(:ngram_size).only_integer.is_greater_than_or_equal_to(2) }
    it { is_expected.to validate_numericality_of(:threshold).is_in(0..1) }

    it { expect(create(:assignment)).to validate_uniqueness_of(:identifier) }
  end
end
