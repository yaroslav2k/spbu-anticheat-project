# frozen_string_literal: true

ActiveAdmin.register Course do
  remove_filter :submissions

  controller do
    actions :all, except: %i[destroy]

    def scoped_collection
      resource_class.where(user: current_user)
    end
  end

  permit_params :title, :year, :semester

  before_build do |record|
    record.user = current_user
    record.year ||= Date.current.year
    record.semester ||= Utilities::DateTime.current_semester.to_s
  end

  index do
    selectable_column

    column :user
    column :year
    column :semester
    column :title

    actions

    column :actions do |_course|
      link_to("groups", admin_groups_url, method: :get)
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      input :title
      input :year
      input :semester
    end

    f.actions
  end
end
