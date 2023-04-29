# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
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
