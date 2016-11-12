Rails.application.routes.draw do

  devise_for :users
  root to: 'application#index.html'
  resources :memberships, only: [:new, :create, :edit, :update, :index, :show]
end
