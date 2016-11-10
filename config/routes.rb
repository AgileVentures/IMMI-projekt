Rails.application.routes.draw do

  root to: 'application#index.html'
  resources :memberships, only: [:new, :create]
end
