# frozen_string_literal: true

class GitRemoteValidator < ActiveModel::EachValidator
  HTTP_REQUEST_EVALUATOR = ->(uri) { HTTParty.head(uri) }

  def initialize(options = {})
    super

    @branch = options[:branch].presence
  end

  def validate_each(record, attribute, value)
    resolved_branch = resolve_branch_option(record)

    return if perform_request(value, branch: resolved_branch).success?

    record.errors.add(attribute, :git_remote_branch_not_found)
  end

  private

    def perform_request(url, branch: nil)
      uri = if branch
        "#{url}/tree/#{branch}"
      else
        url
      end

      HTTP_REQUEST_EVALUATOR[uri]
    end

    def resolve_branch_option(record)
      return unless branch

      if branch.respond_to?(:call) && branch.arity == 1
        branch[record]
      else
        branch
      end
    end

    attr_reader :branch
end
