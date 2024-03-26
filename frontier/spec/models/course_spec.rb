# frozen_string_literal: true

# == Schema Information
#
# Table name: courses
#
#  id         :uuid             not null, primary key
#  group      :citext           not null
#  semester   :string           not null
#  title      :citext           not null
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_courses_on_title_and_year_and_semester  (title,year,semester) UNIQUE
#  index_courses_on_user_id                      (user_id)
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
    it { is_expected.to have_many(:submissions) }
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
    subject(:course) { create(:course) }

    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:year, :semester).case_insensitive }
    it { is_expected.to validate_length_of(:title).is_at_least(3).is_at_most(40) }
    it { is_expected.to validate_inclusion_of(:semester).in_array(%w[spring fall]) }
    it { is_expected.to validate_numericality_of(:year).only_integer }
  end

  describe "instance methods" do
    subject(:course) { create(:course) }

    before { create(:assignment, course:) }

    def perform(course) = course.prolongeable_copy

    specify do
      result = perform(course)

      expect(result).to be_a_new_record
      expect(result.user).to eq(course.user)
      expect(result).to have_attributes(
        id: nil,
        year: Time.zone.now.year,
        semester: Utilities::DateTime.current_semester.to_s,
        user: be_present,
        assignments: be_none
      )
      expect(result.attributes.except("id", "updated_at", "created_at", "semester", "year"))
        .to eq(course.attributes.except("id", "updated_at", "created_at", "semester", "year"))
    end
  end
end
