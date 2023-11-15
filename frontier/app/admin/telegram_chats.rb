# frozen_string_literal: true

ActiveAdmin.register TelegramChat do
  permit_params :name, :group

  index do
    selectable_column

    column :name
    column :group

    actions
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      input :name
      input :group
    end

    f.actions
  end
end
