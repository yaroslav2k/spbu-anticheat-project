# frozen_string_literal: true

# == Schema Information
#
# Table name: groups
#
#  id         :uuid             not null, primary key
#  title      :citext           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :uuid             not null
#
# Indexes
#
#  index_groups_on_course_id  (course_id)
#  index_groups_on_title      (title) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
RSpec.describe Group do
  subject(:group) { build(:group) }

  describe "factories" do
    it { is_expected.to be_valid }
  end

  describe "validations" do
    it { is_expected.to validate_uniqueness_of(:title) }
  end
end
