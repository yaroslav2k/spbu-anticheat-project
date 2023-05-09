# frozen_string_literal: true

ActiveAdmin.register Submission do
  actions :index, :show

  index do
    column :assignment
    column :url
    column :branch
    column :author
    column :status

    column :sent_at
  end
end
