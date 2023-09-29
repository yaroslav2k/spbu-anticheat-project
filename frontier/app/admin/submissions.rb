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
    column :author
    column :status

    column :source do |submission|
      link_to submission.source_label, submission.source_url, target: "_blank", rel: "noopener"
    end

    column :sent_at
  end
end
