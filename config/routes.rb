# frozen_string_literal: true

Rails.application.routes.draw do
  resources :word_chain_walks, only: %i[index create destroy show] do
    scope module: :word_chain_walks do
      resource :completion, only: %i[update show]
      resources :word_chain_walk_steps, only: %i[new create show] do
        delete 'latest', on: :collection, action: :destroy_latest
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'word_chain_walks#index'
end
