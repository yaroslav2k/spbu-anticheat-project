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

    column :tokens do |submission|
      link_to "link", Storage::PRIMARY.public_url(submission.storage_key), target: "_blank"
    end
  end
end
