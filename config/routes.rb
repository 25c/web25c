Web25c::Application.routes.draw do
  root :to => 'home#index'
  
  match 'register' => 'users#new', :via => :get, :as => :register
  match 'register' => 'users#create', :via => :post
  
  match 'sign-in' => 'users#sign_in', :as => :sign_in
  match 'sign-out' => 'users#sign_out', :as => :sign_out
  match 'auth/:provider/callback' => 'users#sign_in_callback'
  
  match 'about' => 'home#about', :as => :about
  match 'faq' => 'home#faq', :as => :faq
  match 'terms' => 'home#terms', :as => :terms
  match 'privacy' => 'home#privacy', :as => :privacy
  match 'contact' => 'home#contact', :as => :contact
  
  match 'tip/:button_id' => 'users#tip', :as => :tip
  match 'confirm_tip' => 'users#confirm_tip', :as => :confirm_tip
  
  namespace :home do
    resources :buttons
    match 'dismiss_welcome' => 'buttons#dismiss_welcome', :as => :dismiss_welcome, :via => :post
    match '' => 'dashboard#index', :as => :dashboard
    match 'delete-click' => 'dashboard#delete_click', :as => :delete_click, :via => :post
    match 'jar' => 'account#jar', :as => :jar
    match 'confirm_payment' => 'account#confirm_payment', :as => :confirm_payment, :via => :post
    match 'set_refill' => 'account#set_refill', :as => :set_refill, :via => :post
    match 'payout' => 'account#payout', :as => :payout
    match 'confirm_payout' => 'account#confirm_payout', :as => :confirm_payout, :via => :post
  end
  match 'home/account' => 'users#edit', :as => :home_account, :via => :get
  match 'home/account' => 'users#update', :via => :put
  match 'home/profile' => 'users#edit_profile', :as => :home_profile, :via => :get
  match 'home/profile' => 'users#update_profile', :via => :put
  
  namespace :admin do
    resources :users, :except => [ :new, :create ]
    match '' => 'dashboard#index', :as => :dashboard
  end
  
  # the profile wildcard route must be last
  match ':id' => 'users#show', :as => :profile
  
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
