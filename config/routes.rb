Rails.application.routes.draw do

  mount Ckeditor::Engine => '/ckeditor'
  filter :locale

  # Override Devise::RegistrationsController so that we can do some custom things.
  devise_for :users, controllers: { registrations: 'registrations' }

  as :user do

    authenticated :user, lambda { |u| u.admin? } do

      namespace :admin_only, path: 'admin' do
        resources :master_checklists
        get  'master-checklists/max-list-position', to: 'master_checklists#max_list_position'
        post 'master-checklists/toggle-in-use', to: 'master_checklists#toggle_in_use'
        post 'master-checklists/set-to-no-longer-used/:id', to: 'master_checklists#set_to_no_longer_used',
             as: :master_checklists_set_to_no_longer_used

        get 'master-checklists/next-onebased-list-position', to: 'master_checklists#next_one_based_list_position'

        get 'payments', to: 'dashboard#payments'

        resources :master_checklist_types

        # Update membership status for all users
        get 'anvandare/update-membership-status-all', to: 'user_account#update_membership_status_all',
            as: :update_membership_status_all

      end


      # UserChecklists - that only an admin do:
      # View all the checklists for a user
      get 'admin/anvandare/:user_id/lista', to: 'user_checklists#index',
          as: 'user_checklists'

      # Export Information (CSV files)
      post 'admin/export-ansokan-csv'
      post 'admin/export-payments-csv'
      put 'admin/export-payments-covering-year-csv'

      # Route for testing Exception Notification configuration
      get "test_exception_notifications" => "application#test_exception_notifications"

      root to: 'shf_applications#index', as: :admin_root

    end
  end

  # ---------------------------------------------------------------------------
  # We're already using 'admin' as the name of a user role, so we
  # use "admin_only" here to avoid colliding with that term with the
  # namespace directories and class names.  We keep 'admin' as the path
  # for simplicity and some consistency.
  # namespace :admin_only, path: 'admin' do
  namespace :admin_only, path: 'admin' do

    resources :member_app_waiting_reasons

    get 'dashboard', to: 'dashboard#index'
    put 'dashboard_timeframe', to: 'dashboard#update_timeframe'

    put 'dashboard_show_recent_activity', to: 'dashboard#show_recent_activity'


    # AppConfiguration is a Singleton.
    # Admins only view and edit the AppConfiguration.
    # There is no need for index or destroy.
    #
    # :id is an optional parameter so that view buttons, etc., work fine
    # with the Rails conventions
    #
    # as: :..app_configuration..  is needed when the id is an optional parameter

    get 'app_configuration(/:id)/redigera', to: 'app_configuration#edit',
        as: :edit_app_configuration

    # must use the as: :put_app_configuration so that the method does not conflict with get 'app_configuration(/:id)' route (#show)
    put 'app_configuration(/:id)', to: 'app_configuration#update', as: :put_app_configuration

    get 'app_configuration(/:id)', to: 'app_configuration#show', as: :app_configuration


    get 'user_profile_edit/:id', to: 'user_profile#edit', as: :user_profile_edit
    put 'user_profile_update/:id', to: 'user_profile#update', as: :user_profile_update
    get 'user_profile_become/:id', to: 'user_profile#become', as: :become_user

    # Edit User Account
    get 'anvandare/:user_id/redigera', to: 'user_account#edit', as: :edit_user_account
    put 'anvandare/:user_id', to: 'user_account#update', as: :user_account

    # Design Guide
    get 'designguide', to: 'design_guide#show'

  end
  # ---------------------------------------------------------------------------

  get '/pages/*id', to: 'pages#show', as: :page, format: false


  scope(path_names: { new: 'ny', edit: 'redigera' }) do
    resources :business_categories, path: 'kategori' do
      get :get_edit_row, on: :member
      get :get_display_row, on: :member
    end

    resources :shf_applications, path: 'ansokan' do
      member do
        put 'remove_attachment'

        put 'update-reason-waiting', to: 'shf_applications#update_reason_waiting',
            as: 'reason_waiting'

        get 'start-review', to: 'shf_applications#show'
        post 'start-review', to: 'shf_applications#start_review'

        get 'accept', to: 'shf_applications#show'
        post 'accept', to: 'shf_applications#accept'
        get 'reject', to: 'shf_applications#show'
        post 'reject', to: 'shf_applications#reject'
        get 'need-info', to: 'shf_applications#show'
        post 'need-info', to: 'shf_applications#need_info'
        get 'cancel-need-info', to: 'shf_applications#show'
        post 'cancel-need-info', to: 'shf_applications#cancel_need_info'
        get 'need-payment', to: 'shf_applications#show'
        post 'need-payment', to: 'shf_applications#need_payment'
        get 'cancel-need-payment', to: 'shf_applications#show'
        post 'cancel-need-payment', to: 'shf_applications#cancel_need_payment'
        get 'received-payment', to: 'shf_applications#show'
        post 'received-payment', to: 'shf_applications#received_payment'

        get 'get_edit_row_business_category'
        get 'get_display_row_business_category'

        put 'business_subcategories'
      end

    end

    resources :companies, path: 'hundforetag' do
      member do
        put 'edit_payment', to: 'companies#edit_payment', as: 'edit_payment'
        post 'fetch_from_dinkurs', to: 'companies#fetch_from_dinkurs', as: 'fetch_from_dinkurs'
      end
    end


    # User Account.  Only admins can edit (see the route above for /admin)
    resources :users, path: 'anvandare', except: [:edit, :update]  do
      member do
        put 'edit_status', to: 'users#edit_status', as: 'edit_status'
      end

      post 'toggle_membership_package_sent', to: 'users#toggle_membership_package_sent'

      # ---------------------------------------------------
      # UserChecklist as a nested resource under User, with path '/lista' in the URI
      resources :user_checklists, only: [:show], path: 'lista' do
        get 'progress', to: 'user_checklists#show_progress'
      end


      # ---------------------------------------------------
      # Uploaded files

      # Do these 2 routes manually so that we can add the optional parameter :from_acct_pg
      # They must go before the resources :uploaded_files... statement below so that
      #  /anvandare/:user_id/filer/ny is matched to the request before
      #  /anvandare/:user_id/filer/:id  otherwise the router will think that :id = 'ny'
      #
      get 'filer/ny(/:from_acct_pg)', to: 'uploaded_files#new',
          as: 'new_uploaded_file'
      post 'filer/(/:from_acct_pg)', to: 'uploaded_files#create'

      # UploadedFile as a nested resource under User, with page '/filer' in the URI
      resources :uploaded_files, path: 'filer', except: [:new, :create]

    end

    # UserChecklists
    post 'anvandare/lista/all_changed_by_completion_toggle/:id', to: 'user_checklists#all_changed_by_completion_toggle',
         as: 'user_checklist_all_changed_by_completion_toggle'
    post 'anvandare/lista/set-all-completed/:id', to: 'user_checklists#set_complete_including_kids',
         as: 'user_checklist_set_complete_including_kids'
    post 'anvandare/lista/set-all-uncompleted/:id', to: 'user_checklists#set_uncomplete_including_kids',
         as: 'user_checklist_set_uncomplete_including_kids'


    get 'anvandare/:id/proof_of_membership', to: 'users#proof_of_membership',
        as: 'proof_of_membership'

    get 'hundforetag/:id/company_h_brand', to: 'companies#company_h_brand',
        as: 'company_h_brand'

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


  root to: 'companies#index'

end
