Web25c::Application.routes.draw do
  
  # root :to => 'home#index'
  root :to => 'home#index'
  
  match 'coming_soon' => 'home#coming_soon', :as => :coming_soon

  match 'auth/dwolla/callback' => 'home/payout#index', :as => :dwolla_auth_callback
  
  match 'register' => 'users#create', :via => :post, :as => :register

  match 'sign-in' => 'sessions#new', :as => :sign_in, :via => :get
  match 'sign-in' => 'sessions#create', :via => :post
  match 'sign-out' => 'sessions#destroy', :as => :sign_out
  match 'request-password' => 'sessions#request_password', :as => :request_password
  match 'reset-password/:id' => 'sessions#reset_password', :as => :reset_password
  match 'auth/:provider/callback' => 'sessions#create'

  match 'about' => 'home#about', :as => :about
  match 'faq' => 'home#faq', :as => :faq
  match 'fees' => 'home#fees', :as => :fees
  match 'terms' => 'home#terms', :as => :terms
  match 'privacy' => 'home#privacy', :as => :privacy

  match 'tip/:button_id' => 'users#tip', :as => :tip
  match 'blog/header' => 'home#blog_header'
  match 'blog/footer' => 'home#blog_footer'
  match 'paypal_process' => 'home#paypal_process', :as => :paypal_process
  
  # endpoints for Facebook Open Graph links
  match 'notes/:uuid' => 'open_graph#note', :as => :note
  match 'webpages/:uuid' => 'open_graph#webpage', :as => :webpage
  
  resources :i, :controller => 'invites', :as => 'invites', :only => [ :index, :show, :update ]
  
  namespace :tipper do
  
    # Dashboard
    match '' => 'dashboard#index', :as => :dashboard
    match 'cancel' => 'dashboard#cancel_click', :as => :cancel_click, :via => :delete
    
    # Payment
    match 'payment' => 'payment#index', :as => :payment
    match 'tip_register' => 'payment#tip_register', :as => :tip_register
    match 'site_register' => 'payment#site_register', :as => :site_register
    match 'payment/success' => 'payment#payment_success', :as => :payment_success
    match 'payment/failure' => 'payment#payment_failure', :as => :payment_failure
    match 'payment/dwolla'  => 'payment#payment_dwolla', :as => :payment_dwolla
    match 'create_payment' => 'payment#create_payment', :as => :create_payment, :via => :post
    
    # Account
    match 'account' => 'account#edit', :as => :account, :via => :get
    
  end
  
  namespace :publisher do
    
    # Widgets
    match 'widgets' => 'widgets#index', :as => :widgets
    match 'widgets/new' => 'widgets#new', :as => :new_widget, :via => :get
    match 'widgets/new' => 'widgets#create', :via => :post
    match 'widgets/edit/:uuid' => 'widgets#edit', :as => :edit_widget, :via => :get
    match 'widgets/edit/:uuid' => 'widgets#update', :via => :put
    match 'widgets/delete/:uuid' => 'widgets#destroy', :as => :delete_widget
    
    # Revenue Sharing
    match 'share_email' => 'widgets#share_email', :as => :share_email, :via => :put
    match 'cancel_email' => 'widgets#cancel_email', :as => :cancel_email, :via => :delete
    match 'stop_share' => 'widgets#stop_share', :as => :stop_share, :via => :delete
    
    # Dashboard
    match '' => 'dashboard#index', :as => :dashboard

    # Payout
    match 'payout' => 'payout#index', :as => :payout
    match 'create_payment' => 'payout#create_payment', :as => :create_payment, :via => :post
    
    # Account
     match 'account' => 'account#edit', :as => :account, :via => :get
      
    match 'publisher/profile' => 'users#profile', :as => :publisher_profile
    # match 'home/choose_nickname' => 'users#choose_nickname', :as => :choose_nickname
    
  end
  
  namespace :admin do
    resources :users, :except => [ :new, :create ]
    match '' => 'dashboard#index', :as => :dashboard
    match 'process_payment' => 'dashboard#process_payment', :as => :process_payment, :via => :post
    match 'test' => 'dashboard#test', :as => :test
  end
  
  # catch-all 404 page for unknown routes
  match '*a' => 'home#not_found', :as => :not_found

end
