# frozen_string_literal: true

class Tasks::CreateJob < ApplicationJob
  def perform(url)
    puts url
  end
end