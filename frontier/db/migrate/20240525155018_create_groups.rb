# frozen_string_literal: true

class CreateGroups < ActiveRecord::Migration[7.1]
  def up
    create_table :groups, id: :uuid do |t|
      t.references :course, index: true, foreign_key: true, type: :uuid, null: false

      t.string :title, null: false, index: { unique: true }

      t.timestamps
    end

    reversible do |direction|
      direction.up do
        Course.find_each do |course|
          Group.create!(title: course.group, course:)
        end
      end
    end

    remove_column :courses, :group, :citext
  end

  def down
    drop_table :groups

    t.citext :group, null: true

    Group.each do |group|
      group.course.update!(group: group.title)
    end
  end
end
