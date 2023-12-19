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

      if submission.of_type.files_group?
        row :uploads do
          safe_join(
            submission.uploads.reduce([]) do |links, upload|
              links << link_to(upload.filename, upload.source_url, target: "_blank", rel: "noopener")
            end, tag.br
          )
        end
      elsif submission.of_type.git?
        row :"Github URL" do
          link_to submission.url, submission.url, target: "_blank", rel: "noopener"
        end

        row :branch do
          submission.branch
        end
      end
    end
  end
end
