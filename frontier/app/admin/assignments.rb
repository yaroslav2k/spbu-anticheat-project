# frozen_string_literal: true

ActiveAdmin.register Assignment do
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :user_id, :status, :identifier
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :status, :identifier]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  controller do
    def scoped_collection
      resource_class.where(user: current_user)
    end
  end

  permit_params :title, :year

  before_build do |record|
    record.user = current_user
    record.year = Date.current.year
  end

  index do
    selectable_column

    column :year
    column :title
    column :identifier
    column :user
  end

  form do |f|
    f.semantic_errors

    f.inputs do
      input :title
      input :year
    end

    f.actions
  end
end
