# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  namespace :api do
    resource :status, only: %i[show]
    resources :tasks, only: %i[create]
  end

  namespace :gateway do
    namespace :telegram do
      resources :webhooks, only: %i[] do
        post :notify, on: :collection
      end
    end
  end
end
