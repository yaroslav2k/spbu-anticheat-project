# frozen_string_literal: true

Rails.application.routes.draw do
  mount HealthMonitor::Engine => "/status"

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"

  devise_for :users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  root to: "admin/dashboard#index"

  namespace :api, defaults: { format: "json" } do
    resource :status, only: %i[show]

    resources :courses, only: %i[create index]
    resources :assignments, only: %i[index show]

    resources :submissions, only: %i[update]
  end

  namespace :gateway do
    namespace :telegram do
      resources :webhooks, only: %i[] do
        post :notify, on: :collection
      end
    end
  end
end
