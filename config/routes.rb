Web25c::Application.routes.draw do
  root :to => 'home#index'
  
  # match 'register' => 'users#new', :via => :get, :as => :register
  # match 'register' => 'users#create', :via => :post
  
  match 'sign-in' => 'users#sign_in', :as => :sign_in
  match 'sign-out' => 'users#sign_out', :as => :sign_out
  match 'auth/paypal/callback' => 'home/account#payout'
  match 'auth/:provider/callback' => 'users#sign_in_callback'
  
  match 'about' => 'home#about', :as => :about
  match 'faq' => 'home#faq', :as => :faq
  match 'fees' => 'home#fees', :as => :fees
  match 'terms' => 'home#terms', :as => :terms
  match 'privacy' => 'home#privacy', :as => :privacy
  
  match 'tip/:button_id' => 'users#tip', :as => :tip
  match 'fb_share_callback' => 'home#fb_share_callback'
  match 'blog/header' => 'home#blog_header'
  match 'blog/footer' => 'home#blog_footer'
  
  namespace :home do
    # Buttons
    resources :buttons
    match 'update_button' => 'buttons#update_button', :as => :update_button, :via => :put
        
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
  match 'home/user_agreement' => 'users#user_agreement', :as => :user_agreement
  
  namespace :admin do
    resources :users, :except => [ :new, :create ]
    match '' => 'dashboard#index', :as => :dashboard
    match 'process_payment' => 'dashboard#process_payment', :as => :process_payment, :via => :post
  end
  
  # the profile wildcard route must be last
  match ':id' => 'users#show', :constraints => { :id => /.*/ }, :as => :profile
  
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
