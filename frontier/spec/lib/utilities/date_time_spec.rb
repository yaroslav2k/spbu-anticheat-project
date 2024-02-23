# frozen_string_literal: true

RSpec.describe Utilities::DateTime do
  describe ".current_semester" do
    it { expect(described_module.current_semester(Date.parse("Feb 08, 2000"))).to eq(:spring) }
    it { expect(described_module.current_semester(Date.parse("Jan 01, 2024"))).to eq(:fall) }
  end
end
