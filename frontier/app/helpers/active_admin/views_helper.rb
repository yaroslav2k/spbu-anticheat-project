# frozen_string_literal: true

module ActiveAdmin::ViewsHelper
  module_function

  def algorithm_parameter_input(form, parameter, **options)
    if parameter[:type].to_sym.in?(%i[float])
      form.input parameter[:name], as: :number, **numeric_value_boundaries(parameter, options:)
    elsif parameter.key?(:values)
      form.input parameter[:name], as: :select, collection: parameter[:values].map { [_1, _1] }, include_blank: false
    else
      form.input parameter[:name], **options
    end
  end

  def numeric_value_boundaries(parameter, options:)
    options[:input_html] ||= {}
    options[:input_html][:min] ||= parameter[:minimum]
    options[:input_html][:max] ||= parameter[:maximum]
    options[:input_html][:step] ||= parameter[:step]

    options
  end
end
