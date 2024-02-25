# frozen_string_literal: true

helpers = Module.new do
  private

    def validate_model(model, validator, **options)
      with_mocked_errors(model) do |mock|
        validator = build_validator(validator, **options)
        validator.validate(model)
        @real_errors = received_messages(mock)
      end

      expect(@real_errors).to match_array(@errors || [])
    end

    def with_mocked_errors(model)
      mock = instance_double(ActiveModel::Errors, add: true)
      old_errors = model.instance_variable_get(:@errors)
      model.instance_variable_set(:@errors, mock)

      begin
        yield mock
      ensure
        model.instance_variable_set(:@errors, old_errors)
      end

      mock
    end

    def build_validator(validator, **extra_options)
      if validator.is_a?(Class)
        validator.new(**extra_options, **@options.to_h)
      elsif @options.present? || extra_options.present?
        raise "Cannot specify options for already built validator"
      else
        validator
      end
    end

    def received_messages(mock)
      proxy = RSpec::Mocks.space.proxy_for(mock)
      proxy.messages_arg_list
    end

    def render_real_errors
      messages = @real_errors.map do |field, error, **options|
        "errors.add(#{field.inspect}, #{error.inspect}, #{options.inspect})"
      end

      "Actual messages: [\n#{messages.join("\n")}]"
    end

    def chain_error(field, error, options)
      @errors ||= []

      @errors << satisfy do |field_, error_, options_|
        expect(field_.to_sym).to eq field.to_sym
        expect(error_.to_s).to eq error.to_s
        expect(options_).to match(options)
      end
    end
end

RSpec::Matchers.define :validate do |name = :attribute, value, **extra_options|
  include helpers

  match do |validator|
    model = Struct.new(name).new(value)
    model.extend(ActiveModel::Validations)

    validate_model(model, validator, attributes: [name], **extra_options)
  end

  failure_message { render_real_errors }

  chain :and_report_error do |field, error = nil, options = nil|
    if options
      chain_error(field, error, options)
    else
      chain_error(name, field, error)
    end
  end

  chain :with_options do |options|
    @options = options
  end
end
