Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  filter :locale

  devise_for :users

  as :user do
    authenticated :user, lambda {|u| u.admin? }  do
      post 'admin/export-ansokan-csv'

      root to: 'membership_applications#index', as: :admin_root
    end
  end

  # We're already using 'admin' as the name of a user role, so we
  # use "admin_only" here to avoid colliding with that term with the
  # namespace directories and class names.  We keep 'admin' as the path
  # for simplicity and some consistency.
  namespace :admin_only, path: 'admin' do

    resources :member_app_waiting_reasons

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
        get 'need-payment', to: 'membership_applications#show'
        post 'need-payment', to: 'membership_applications#need_payment'
        get 'cancel-need-payment', to: 'membership_applications#show'
        post 'cancel-need-payment', to: 'membership_applications#cancel_need_payment'
        get 'received-payment', to: 'membership_applications#show'
        post 'received-payment', to: 'membership_applications#received_payment'

      end

    end

    resources :companies, path: 'hundforetag'

    resources :users, path: 'anvandare'

    resources :shf_documents

    get 'shf_documents/contents/:page',
      to: 'shf_documents#contents_show', as: 'contents_show'

    get 'shf_documents/contents/:page/redigera',
      to: 'shf_documents#contents_edit', as: 'contents_edit'

    patch 'shf_documents/contents/:page',
      to: 'shf_documents#contents_update', as: 'contents_update'

    get 'member-pages', to: 'shf_documents#minutes_and_static_pages'

  end

  get 'information', to: 'membership_applications#information'

  root to: 'companies#index'

end
