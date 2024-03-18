# frozen_string_literal: true

class RebuildCoursesTitleIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :courses, :title
    add_index :courses, %i[title year semester], unique: true
  end
end
