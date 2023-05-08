# frozen_string_literal: true

ActiveAdmin.register Submission do
  actions :index, :show

  index do
    selectable_column

    column :assignment
    column :url
    column :branch
    column :author
    column :status

    column :created_at
    column :updated_at
  end
end
