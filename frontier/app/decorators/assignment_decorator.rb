# frozen_string_literal: true

class AssignmentDecorator < ApplicationDecorator
  Report = Struct.new(:clusters, keyword_init: true)
  Cluster = Struct.new(:items, keyword_init: true)
  Item = Struct.new(:repository, :file_name, :class_name, :function_name, keyword_init: true) do
    def initialize(...)
      super(...)

      %i[class_name function_name].each do |attribute|
        public_send("#{attribute}=", handle_blank(public_send(attribute)))
      end
    end

    private

      def handle_blank(value)
        value.presence || "—"
      end
  end

  delegate_all

  memoize def report
    parsed_report = JSON.parse(context[:raw_report])

    clusters = parsed_report.map do |raw_cluster|
      items = raw_cluster.map do |raw_item|
        Item.new(raw_item.transform_keys(&:to_s).transform_keys(&:underscore))
      end

      Cluster.new(items: items)
    end

    Report.new(clusters: clusters)
  end
end
