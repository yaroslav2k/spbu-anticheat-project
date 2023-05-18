# frozen_string_literal: true

ActiveAdmin.register Assignment do
  controller do
    def scoped_collection
      resource_class.for(current_user)
    end
  end

  permit_params :title, :course_id

  index do
    selectable_column

    column :course
    column :title
    column :identifier

    column :report do |assignment|
      if assignment.has_report?
        link_to "link", Storage::PRIMARY.public_url(assignment.report_storage_key), target: "_blank"
      else
        "N/A"
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      input :title
      input :course_id, as: :select, collection: Course.all.for(current_user).map { |c| [c.title, c.id] }, include_blank: false
    end

    f.actions
  end
end
