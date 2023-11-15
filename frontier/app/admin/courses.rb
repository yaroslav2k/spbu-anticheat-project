# frozen_string_literal: true

ActiveAdmin.register Course do
  controller do
    def scoped_collection
      resource_class.where(user: current_user)
    end
  end

  permit_params :title, :year, :semester, :group

  before_build do |record|
    record.user = current_user
    record.year ||= Date.current.year
    record.semester ||= "fall" # FIXME
  end

  index do
    selectable_column

    column :user
    column :year
    column :semester
    column :title
    column :group

    actions
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      input :title
      input :year
      input :semester
      input :group
    end

    f.actions
  end
end
