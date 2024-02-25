# frozen_string_literal: true

module Utilities::DateTime
  module_function

  def current_semester(time = Time.zone.now)
    if time.month >= 9 || time.month == 1
      :fall
    else
      :spring
    end
  end
end
