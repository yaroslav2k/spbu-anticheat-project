# frozen_string_literal: true

RSpec.describe URLValidator, type: :validator do
  context "without provided options" do
    specify do
      expect(described_class).to validate("https://google.com")
      expect(described_class).to validate("http://google.com")

      expect(described_class)
        .to validate("  ")
        .and_report_error(:invalid_uri)

      expect(described_class)
        .to validate("ftp://google.com")
        .and_report_error(:invalid_uri)

      expect(described_class)
        .to validate("foobar")
        .and_report_error(:invalid_uri)
    end
  end

  context "with provided `domain` option" do
    specify do
      expect(described_class).to validate("https://gitlab.com/foobar", domain: "gitlab.com")

      expect(described_class)
        .to validate("https://github.com/foobar", domain: "gitlab.com")
        .and_report_error("invalid_domain")
    end
  end
end
