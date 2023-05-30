# frozen_string_literal: true

ActiveAdmin.register Submission do
  controller do
    def scoped_collection
      resource_class.for(current_user)
    end
  end

  actions :index, :show

  config.sort_order = "created_at_desc"

  scope("Recent") { |scope| scope.where(created_at: DateTime.now.beginning_of_day..DateTime.now.end_of_day) }

  index do
    column :assignment
    column :url
    column :branch
    column :author
    column :status

    column :sent_at
  end
end
