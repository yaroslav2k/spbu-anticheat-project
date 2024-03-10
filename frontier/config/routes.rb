# frozen_string_literal: true

Rails.application.routes.draw do
  mount HealthMonitor::Engine, at: "/status"

  devise_for :users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)

  root to: "admin/dashboard#index"

  namespace :api do
    resource :status, only: %i[show]
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
