# frozen_string_literal: true

class ApplicationService
  Success = Struct.new(:success?, :failure?, keyword_init: true)
  Failure = Struct.new(:success?, :failure?, keyword_init: true)

  class << self
    alias build new

    def call(*)
      build(*).call
    end

    private

      def subject(*names)
        if names.size > 1
          names.each do |name|
            define_method(name) { subject.fetch(name) }
          end
        else
          alias_method(names.first, :subject)
        end
      end

      def context(name, default: nil)
        define_method(name) do
          context.fetch(name, default)
        end

        define_method(:"#{name}=") do |value|
          context[name] = value
        end
      end

      def result_on_success(*)
        const_set :Success, Struct.new(*, :success?, :failure?, keyword_init: true)
      end

      def result_on_failure(*)
        const_set :Failure, Struct.new(*, :success?, :failure?, keyword_init: true)
      end
  end

  attr_reader :subject, :context

  def initialize(subject, context = {})
    @subject = subject
    @context = context
  end

  def call
    raise "Not implemented"
  end

  def success!(**)
    self.class::Success.new(success?: true, failure?: false, **)
  end

  def failure!(**)
    self.class::Failure.new(success?: false, failure?: true, **)
  end
end
