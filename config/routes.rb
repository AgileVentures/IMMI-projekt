Rails.application.routes.draw do

  filter :locale

  devise_for :users

  as :user do
    authenticated :user, lambda {|u| u.admin? }  do
      post 'admin/export-ansokan-csv'

      get 'admin', to: 'admin#index'

      root to: 'admin#index', as: :admin_root
    end
  end

  get '/pages/*id', to: 'pages#show', as: :page, format: false


  scope(path_names: { new: 'ny', edit: 'redigera' }) do
    resources :business_categories, path: 'kategori'

    resources :membership_applications, path: 'ansokan' do
      member do
        get 'start-review', to: 'membership_applications#show'
        post 'start-review', to: 'membership_applications#start_review'

        get 'accept', to: 'membership_applications#show'
        post 'accept', to: 'membership_applications#accept'
        get 'reject', to: 'membership_applications#show'
        post 'reject', to: 'membership_applications#reject'
        get 'need-info', to: 'membership_applications#show'
        post 'need-info', to: 'membership_applications#need_info'
        get 'cancel-need-info', to: 'membership_applications#show'
        post 'cancel-need-info', to: 'membership_applications#cancel_need_info'

      end

    end

    resources :companies, path: 'hundforetag'

    resources :users, path: 'anvandare'
  end

  get 'information', to: 'membership_applications#information'

  root to: 'companies#index'

end
