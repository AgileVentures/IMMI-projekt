Rails.application.routes.draw do
  get 'memberships/new'

  get 'memberships/create'

  root to: 'application#index.html'
  resources :memberships, only: [:new, :create]
end
