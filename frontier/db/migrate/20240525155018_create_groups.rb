# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[7.1]
  def up
    create_table :groups, id: :uuid do |t|
      t.references :course, index: true, foreign_key: true, type: :uuid, null: false

      t.citext :title, null: false, index: { unique: true }

      t.timestamps
    end

    Course.find_each do |course|
      Group
        .create_with(course:)
        .find_or_create_by!(title: course.group)
    end

    remove_column :courses, :group, :citext
  end

  def down
    add_column :courses, :group, :citext

    Group.find_each do |group|
      group.course.update!(group: group.title)
    end

    drop_table :groups

    change_column_null :courses, :group, false
  end
end
