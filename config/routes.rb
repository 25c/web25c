Web25c::Application.routes.draw do
  
  # root :to => 'home#index'
  root :to => 'home#index'
  
  match 'coming_soon' => 'home#coming_soon', :as => :coming_soon
  
  # temporary demo page
  match 'demo' => 'home#demo'

  match 'auth/dwolla/callback' => 'home/payout#index', :as => :dwolla_auth_callback
  
  match 'sign-up' => 'users#new', :via => :get, :as => :register
  match 'sign-up' => 'users#create', :via => :post

  match 'sign-in' => 'sessions#new', :as => :sign_in, :via => :get
  match 'sign-in' => 'sessions#create', :via => :post
  match 'sign-out' => 'sessions#destroy', :as => :sign_out
  match 'request-password' => 'sessions#request_password', :as => :request_password
  match 'reset-password/:id' => 'sessions#reset_password', :as => :reset_password
  match 'auth/:provider/callback' => 'sessions#create'
  
  match 'widget/sign-in' => 'sessions#widget_new', :as => :widget_sign_in, :via => :get
  
  match 'about' => 'home#about', :as => :about
  match 'faq' => 'home#faq', :as => :faq
  match 'terms' => 'home#terms', :as => :terms
  match 'privacy' => 'home#privacy', :as => :privacy
  
  match 'blog/header' => 'home#blog_header', :as => :blog_header
  match 'blog/footer' => 'home#blog_footer', :as => :blog_footer
  
  # endpoints for Facebook Open Graph links
  match 'notes/:uuid' => 'open_graph#note', :as => :note
  match 'webpages/:uuid' => 'open_graph#webpage', :as => :webpage
  
  resources :i, :controller => 'invites', :as => 'invites', :only => [ :index, :show, :update ]
  
  namespace :tipper do
  
    # Dashboard
    match '' => 'dashboard#index', :as => :dashboard
    match 'cancel' => 'dashboard#cancel_click', :as => :cancel_click, :via => :delete
    
    # Buy Points
    match 'points' => 'points#index', :as => :points
    match 'points/checkout' => 'points#checkout', :as => :points_checkout
    match 'points/remove-card' => 'points#remove_card', :as => :points_remove_card
    
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
    # Dashboard
    root :to => 'dashboard#index', :as => :dashboard
    match 'request_payout' => 'dashboard#request_payout'
    match 'submit_request' =>  'dashboard#submit_request', :as => :submit_request
    # Widgets
    resources :widgets, :as => :buttons, :except => [ :new, :edit ]
    # Account
    resource :account, :as => :user, :only => [ :show, :update ]
    
    # Revenue Sharing
    match 'share_email' => 'widgets#share_email', :as => :share_email, :via => :put
    match 'cancel_email' => 'widgets#cancel_email', :as => :cancel_email, :via => :delete
    match 'stop_share' => 'widgets#stop_share', :as => :stop_share, :via => :delete    
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
