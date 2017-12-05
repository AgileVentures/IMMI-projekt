Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  filter :locale

  devise_for :users

  as :user do
    authenticated :user, lambda {|u| u.admin? }  do
      post 'admin/export-ansokan-csv'

      # Route for testing Exception Notification configuration
      get "test_exception_notifications" => "application#test_exception_notifications"


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

    resources :companies, path: 'hundforetag' do
      member do
        put 'edit_payment', to: 'companies#edit_payment', as: 'edit_payment'
      end
    end

    resources :users, path: 'anvandare' do
      member do
        put 'edit_status', to: 'users#edit_status', as: 'edit_status'
      end
    end

    resources :shf_documents, path: 'dokument'

    get 'dokument/innehall/:page',
      to: 'shf_documents#contents_show', as: 'contents_show'

    get 'dokument/innehall/:page/redigera',
      to: 'shf_documents#contents_edit', as: 'contents_edit'

    patch 'dokument/innehall/:page',
      to: 'shf_documents#contents_update', as: 'contents_update'

    get 'medlemssidor', to: 'shf_documents#minutes_and_static_pages',
                        as: 'member_pages'

  end

  # We are not using nested resource statements for the following routes
  # because that did not seem to work when used in combination with "path:" option

  # ------- Payment as a nested resource within user --------
  post 'anvandare/:user_id/betalning/:type', to: 'payments#create',
       as: :payments

  get 'anvandare/:user_id/betalning/:id', to: 'payments#success',
      as: :payment_success  # user redirect from HIPS

  get 'anvandare/:user_id/betalning/:id/error', to: 'payments#error',
      as: :payment_error  # user redirect from HIPS

  post 'anvandare/betalning/webhook', to: 'payments#webhook',
       as: :payment_webhook
  # ----------------------------------------------------------

  # ------- Address as a nested resource within company -----
  post 'hundforetag/:company_id/adresser/:id/set_type', to: 'addresses#set_address_type',
       as: :company_address_type  # Used only for XHR action, not visible to user

  get 'hundforetag/:company_id/ny', to: 'addresses#new', as: :new_company_address

  post 'hundforetag/:company_id/adresser', to: 'addresses#create',
       as: :company_addresses

  get 'hundforetag/:company_id/adresser/:id/redigera', to: 'addresses#edit',
       as: :edit_company_address

  put 'hundforetag/:company_id/adresser/:id', to: 'addresses#update',
       as: :company_address

  delete 'hundforetag/:company_id/adresser/:id', to: 'addresses#destroy',
         as: :company_address_delete
  # ----------------------------------------------------------

  get 'information', to: 'membership_applications#information'

  root to: 'companies#index'

end
