# frozen_string_literal: true

ActiveAdmin.register Group do
  controller do
    def scoped_collection
      resource_class.for(current_user)
    end
  end

  index do
    selectable_column

    column :course
    column :title

    column :students do |group|
      link_to("students", admin_students_url(group_id: group.id), method: :get)
    end
  end
end
