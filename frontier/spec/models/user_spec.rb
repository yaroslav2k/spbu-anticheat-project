# frozen_string_literal: true

RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_many(:courses).dependent(:destroy) }
  end
end
