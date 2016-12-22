Rails.application.routes.draw do

  filter :locale

  devise_for :users

  as :user do
    authenticated :user, lambda {|u| u.admin? }  do
      root to: 'admin#index', as: :admin_root
    end
  end

  get '/pages/*id', to: 'pages#show', as: :page, format: false

  scope(path_names: { new: 'ny', edit: 'redigera' }) do
    resources :business_categories, path: 'kategori'
    resources :membership_applications, path: 'ansokan'
    resources :companies, path: 'hundforetag'
  end

  get 'information', to: 'membership_applications#information'

  root to: 'companies#index'

end