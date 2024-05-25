# frozen_string_literal: true

CodeClone = Data.define(:similarity, :code_fragments) do
  def initialize(similarity:, code_fragments:) # rubocop:disable Metrics/PerceivedComplexity
    unless similarity.is_a?(Numeric) && (0..100).cover?(similarity)
      raise ArgumentError, <<~HEREDOC
        Expected `similarity` to be a floating-point number within 0..1 range.
      HEREDOC
    end

    unless code_fragments.is_a?(Array) && code_fragments.all? { _1.is_a?(CodeFragment) }
      raise ArgumentError, <<~HEREDOC
        Expected `code_fragments` to be an instance of array with
        elements of type `CodeFragment`.
      HEREDOC
    end

    grouped_code_fragments = code_fragments.group_by(&:author_name)
    grouped_code_fragments.each_value do |student_code_fragments|
      if student_code_fragments.size > 1 && grouped_code_fragments.keys.size > 1
        (0...student_code_fragments.size - 1).each { code_fragments.delete(code_fragments[_1]) }
      elsif student_code_fragments.size > 1 && grouped_code_fragments.keys.size == 1
        code_fragments = []
      end
    end

    super(similarity: similarity.to_d / 100, code_fragments:)
  end

  def similarity_label
    "#{similarity} / 1.0"
  end
end
