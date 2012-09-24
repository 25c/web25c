Web25c::Application.routes.draw do
  
  # profile wildcard with tip subdomain
  match ':id' => 'users#show', :constraints => { :id => /.*/, :subdomain => 'tip' }, :as => :profile
  
  root :to => 'home#index'
  
  # match 'register' => 'users#new', :via => :get, :as => :register
  # match 'register' => 'users#create', :via => :post
  
  match 'sign-in' => 'users#sign_in', :as => :sign_in
  match 'sign-out' => 'users#sign_out', :as => :sign_out
  match 'auth/dwolla/callback' => 'home/account#payout', :as => :dwolla_auth_callback
  match 'auth/:provider/callback' => 'users#sign_in_callback'
  
  match 'about' => 'home#about', :as => :about
  match 'faq' => 'home#faq', :as => :faq
  match 'fees' => 'home#fees', :as => :fees
  match 'terms' => 'home#terms', :as => :terms
  match 'privacy' => 'home#privacy', :as => :privacy
  
  match 'tip/:button_id' => 'users#tip', :as => :tip
  match 'blog/header' => 'home#blog_header'
  match 'blog/footer' => 'home#blog_footer'
  match 'fb_share_callback' => 'home#fb_share_callback', :as => :fb_share_callback
  match 'paypal_process' => 'home#paypal_process'
  
  namespace :home do
    # Buttons
    resources :buttons
    match 'update_button' => 'buttons#update_button', :as => :update_button, :via => :put
    match 'get_button' => 'buttons#get_button', :as => :get_button
    match 'receive_pledges' => 'buttons#receive_pledges', :as => :receive_pledges
    match 'choose_pledge_message' => 'buttons#choose_pledge_message', :as => :choose_pledge_message
        
    # Dashboard
    match '' => 'dashboard#index', :as => :dashboard
    match 'undo_clicks' => 'dashboard#undo_clicks', :as => :undo_clicks
    match 'delete_click' => 'dashboard#delete_click', :as => :delete_click, :via => :post
    match 'process_clicks' => 'dashboard#process_clicks', :as => :process_clicks, :via => :post
    
    # Account
    match 'payment' => 'account#payment', :as => :payment
    match 'payment/success' => 'account#payment_success', :as => :payment_sucess
    match 'payment/failure' => 'account#payment_failure', :as => :payment_failure
    match 'payout' => 'account#payout', :as => :payout
    match 'create_payment' => 'account#create_payment', :as => :create_payment, :via => :post
  end
  
  match 'home/account' => 'users#edit', :as => :home_account, :via => :get
  match 'home/account' => 'users#update', :via => :put
  # hidden iframe page for ajax-like picture loading
  match 'home/upload_picture' => 'users#upload_picture', :as => :upload_picture
  match 'home/profile' => 'users#profile', :as => :home_profile
  match 'home/choose_nickname' => 'users#choose_nickname', :as => :choose_nickname
  
  namespace :admin do
    resources :users, :except => [ :new, :create ]
    match '' => 'dashboard#index', :as => :dashboard
    match 'process_payment' => 'dashboard#process_payment', :as => :process_payment, :via => :post
    match 'test' => 'dashboard#test', :as => :test
  end
  
  mount Resque::Server.new, :at => "/admin/resque/frame"
  
  # profile wildcard without tip subdomain
  match ':id' => 'users#show', :constraints => { :id => /.*/ }
  
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
