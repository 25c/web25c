Web25c::Application.routes.draw do
  
  # endpoints for both 'tip' and 'www' domains
  match 'fb_share_callback' => 'home#fb_share_callback', :as => :fb_share_callback
  # hidden iframe page for ajax-like picture loading
  match 'home/upload_picture' => 'users#upload_picture', :as => :upload_picture

  namespace :publisher do
    match 'update_button' => 'buttons#update_button', :as => :update_button, :via => :put
  end
  
  # wildcard routes for profiles under 'tip' domain
  match ':id' => 'users#show', :constraints => { :id => /.*/, :subdomain => 'tip' }, :as => :profile
  
  # 'www' subdomain routes
  defaults :subdomain => Rails.env.development? ? nil : "www" do

    root :to => 'home#index'

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
    
    resources :i, :controller => 'invites', :as => 'invites', :only => [ :index, :show, :update ]
    
    namespace :tipper do
    
      # Dashboard
      match '' => 'dashboard#index', :as => :dashboard
      match 'undo_clicks' => 'dashboard#undo_clicks', :as => :undo_clicks
      match 'delete_click' => 'dashboard#delete_click', :as => :delete_click, :via => :post
      match 'process_clicks' => 'dashboard#process_clicks', :as => :process_clicks, :via => :post
      
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
    
      # Buttons
      resources :buttons
      match 'get_button' => 'buttons#get_button', :as => :get_button
      match 'receive_pledges' => 'buttons#receive_pledges', :as => :receive_pledges
      match 'choose_pledge_message' => 'buttons#choose_pledge_message', :as => :choose_pledge_message
      
      # Dashboard
      match '' => 'dashboard#index', :as => :dashboard
  
      # Payout
      match 'payout' => 'payout#index', :as => :payout
      match 'create_payment' => 'payout#create_payment', :as => :create_payment, :via => :post
      
      # Account
       match 'account' => 'account#edit', :as => :account, :via => :get
      
      # Revenue Sharing
      match 'share_email' => 'buttons#share_email', :as => :share_email, :via => :put
      match 'cancel_email' => 'buttons#cancel_email', :as => :cancel_email, :via => :delete
      match 'stop_share' => 'buttons#stop_share', :as => :stop_share, :via => :delete
      
    end

    match 'publisher/profile' => 'users#profile', :as => :publisher_profile
    # match 'home/choose_nickname' => 'users#choose_nickname', :as => :choose_nickname

    namespace :admin do
      resources :users, :except => [ :new, :create ]
      match '' => 'dashboard#index', :as => :dashboard
      match 'process_payment' => 'dashboard#process_payment', :as => :process_payment, :via => :post
      match 'test' => 'dashboard#test', :as => :test
    end

    mount Resque::Server.new, :at => "/admin/resque/frame"

    # profile wildcard
    match ':id' => 'users#show', :constraints => { :id => /.*/ }
  end
  
  # catch-all 404 page for unknown routes
  match '*a' => 'home#not_found', :as => :not_found
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
