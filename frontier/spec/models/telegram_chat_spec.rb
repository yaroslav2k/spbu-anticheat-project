# frozen_string_literal: true

# == Schema Information
#
# Table name: telegram_chats
#
#  id                       :uuid             not null, primary key
#  external_identifier      :string           not null
#  group                    :string
#  name                     :string
#  status                   :string           default("created"), not null
#  username                 :string           not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  last_submitted_course_id :uuid
#
# Indexes
#
#  index_telegram_chats_on_external_identifier       (external_identifier) UNIQUE
#  index_telegram_chats_on_last_submitted_course_id  (last_submitted_course_id)
#
# Foreign Keys
#
#  fk_rails_...  (last_submitted_course_id => courses.id)
#
RSpec.describe TelegramChat do
  describe "enumerations" do
    subject(:telegram_chat) { build(:telegram_chat) }

    specify do
      expect(telegram_chat).to enumerize(:status)
        .in(%w[created name_provided group_provided])
        .with_default("created")
        .with_predicates(true)
    end
  end

  describe "validations" do
    subject(:telegram_chat) { create(:telegram_chat) }

    it { is_expected.to validate_uniqueness_of(:external_identifier) }
    it { is_expected.to validate_presence_of(:external_identifier) }
    it { is_expected.to validate_presence_of(:username) }
  end

  describe "associations" do
    it { is_expected.to have_many(:telegram_forms).dependent(:destroy) }
    it { is_expected.to belong_to(:last_submitted_course).class_name("Course").optional }
  end

  describe "instance methods" do
    describe "#completed?" do
      it { expect(build(:telegram_chat)).not_to be_completed }
      it { expect(build(:telegram_chat, :with_status_name_provided)).not_to be_completed }
      it { expect(build(:telegram_chat, :with_status_group_provided)).to be_completed }
    end

    describe "#latest_submitted_course" do
      subject(:telegram_chat) { create(:telegram_chat) }

      let(:telegram_chat_without_forms) { create(:telegram_chat) }

      let(:course_1) { create(:course) }
      let(:course_2) { create(:course) }

      let!(:telegram_form_1) { create(:telegram_form, :uploads_provided, course: course_1, telegram_chat:, updated_at: 1.year.ago) }
      let!(:telegram_form_2) { create(:telegram_form, :uploads_provided, course: course_2, telegram_chat:, updated_at: 1.day.ago) }

      its(:latest_submitted_course) { is_expected.to eq(course_2) }

      it { expect(telegram_chat_without_forms.latest_submitted_course).to be_nil }
    end
  end
end
