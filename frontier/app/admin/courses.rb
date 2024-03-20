# frozen_string_literal: true

ActiveAdmin.register Course do
  controller do
    actions :all, except: %i[destroy]

    def scoped_collection
      resource_class.where(user: current_user)
    end
  end

  member_action :prolongate, method: :post do
    course = Course.for(current_user).find(params[:id])

    new_course = course.prolongeable_copy.tap(&:save!)

    redirect_back_or_to root_path, notice: "Created new course (#{new_course.semester} #{new_course.year})"
  rescue ActiveRecord::RecordInvalid => e
    redirect_back_or_to root_path, alert: e.record.errors.full_messages.join("; ")
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

    column :actions do |course|
      link_to("prolongate", prolongate_admin_course_path(course), method: :post)
    end

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
