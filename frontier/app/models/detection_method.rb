# frozen_string_literal: true

DetectionMethod = Data.define(:name, :parameters, :supported_languages) do
  def self.unmarshal(data)
    raise "Invalid `data` argument type, expected `#{Hash.class.inspect}`, got: `#{data.class.inspect}`" unless data.is_a?(Hash)

    data
      .deep_symbolize_keys
      .fetch(:"detection-methods")
      .map { |detection_method| unmarshal_detection_method(detection_method) }
  end

  def self.unmarshal_detection_method(data)
    new(
      name: data.fetch(:name),
      parameters: data.fetch(:parameters),
      supported_languages: data.fetch(:"supported-languages")
    )
  end

  def self.source_data
    @source_data ||= YAML.load_file("config/detection_methods.yml", aliases: true) # rubocop:disable ThreadSafety/InstanceVariableInClassMethod
  end

  self::ALL = unmarshal(source_data)
  self::DEFAULT = unmarshal_detection_method(source_data.fetch("detection-method-default").deep_symbolize_keys)
end
