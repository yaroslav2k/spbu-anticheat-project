# frozen_string_literal: true

class AssignmentDecorator < ApplicationDecorator
  include Memery

  ITEM_ATTRIBUTES = %i[
    repository_url
    revision
    file_name
    class_name
    function_name
    function_start
    function_end
  ].freeze

  Report = Struct.new(:clusters, keyword_init: true)
  Cluster = Struct.new(:items, keyword_init: true)
  Item = Struct.new(*ITEM_ATTRIBUTES, keyword_init: true) do
    def initialize(...)
      super(...)

      %i[class_name function_name].each do |attribute|
        public_send(:"#{attribute}=", handle_blank(public_send(attribute)))
      end

      self.file_name = file_name.split("/")[4..].join("/")
    end

    def external_url
      path = "tree/#{revision}/#{file_name}"
      "#{repository_url}/#{path}?plain=#L#{function_start}-#L#{function_end}"
    end

    private

      def handle_blank(value)
        value.presence || "—"
      end
  end

  delegate_all

  memoize def report
    parsed_report = JSON.parse(context[:raw_report], symbolize_names: true)

    # metadata = parsed_report[:metadata]
    clusters = parsed_report[:clusters]

    clusters = clusters.map do |raw_cluster|
      items = raw_cluster.map do |raw_item|
        Item.new(raw_item.transform_keys(&:to_s).transform_keys(&:underscore))
      end

      Cluster.new(items:)
    end

    Report.new(clusters:)
  end
end
