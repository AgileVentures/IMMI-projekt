Rails.application.routes.draw do

  filter :locale

  devise_for :users

  as :user do
    authenticated :user, lambda {|u| u.admin? }  do
      root to: 'admin#index', as: :admin_root
    end
  end

  get "/pages/*id" => 'pages#show', as: :page, format: false

  resources :business_categories
  resources :membership_applications, only: [:new, :create, :edit, :update, :index, :show]
  resources :companies, only: [:new, :create, :edit, :update, :index, :show]

  get 'information', to: 'membership_applications#information'

  root to: 'companies#index'

end