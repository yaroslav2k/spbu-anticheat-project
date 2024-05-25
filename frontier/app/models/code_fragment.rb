# frozen_string_literal: true

CodeFragment = Data.define(:identifier, :line_start, :line_end) do
  def initialize(identifier:, line_start:, line_end:)
    raise ArgumentError, "Expected `identifier` to be a string, got `#{identifier.inspect}`" unless identifier.is_a?(String)

    unless line_start.is_a?(Integer) && line_start.positive?
      raise ArgumentError, "Expected `line_start` to be a positive integer, got `#{line_start.inspect}`"
    end

    unless line_end.is_a?(Integer) && line_end.positive?
      raise ArgumentError, "Expected `line_end` to be a positive integer, got `#{line_end.inspect}`"
    end

    @upload_id ||= identifier.split("/").last.gsub(/\..+\Z/, "")

    load_submission

    super
  end

  def upload
    return @upload if defined?(@upload)

    @upload = suppress(ActiveRecord::RecordNotFound) do
      Upload.find(upload_id)
    end
  end

  def submission
    return @submission if defined?(@submission)

    @submission = upload.uploadable
  end
  alias_method :load_submission, :submission

  def author_name
    submission&.author_name || "-"
  end

  private

    attr_reader :upload_id
end
