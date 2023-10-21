# frozen_string_literal: true

ActiveAdmin.register Submission do
  controller do
    def scoped_collection
      resource_class.for(current_user)
    end
  end

  actions :index, :show

  config.sort_order = "created_at_desc"

  scope("Recent") { |scope| scope.where(created_at: DateTime.now.all_day) }

  index do
    column :assignment
    column :author_name
    column :status
    column :type

    column :sent_at

    actions
  end

  show do
    attributes_table do
      row :assignment
      row :author_name
      row :author_group
      row :status

      row :uploads do |submission|
        safe_join(
          submission.uploads.reduce([]) do |links, upload|
            links << link_to(upload.filename, upload.source_url, target: "_blank", rel: "noopener")
          end, tag.br
        )
      end
    end
  end
end
