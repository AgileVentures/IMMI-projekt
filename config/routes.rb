Rails.application.routes.draw do

  devise_for :users
  root to: 'application#index.html'

  resources :business_categories
  resources :membership_applications, only: [:new, :create, :edit, :update, :index, :show]
  resources :companies, only: [:new, :create, :edit, :update, :index, :show]
end
