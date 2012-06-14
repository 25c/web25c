Web25c::Application.routes.draw do
  root :to => 'home#index'

  # match 'button/:id' => 'button#button', :as => :button
  
  match 'register' => 'users#new', :via => :get, :as => :register
  match 'register' => 'users#create', :via => :post
  
  match 'sign-in' => 'home#sign_in', :as => :sign_in
  match 'sign-out' => 'home#sign_out', :as => :sign_out
  
  resources :users, :only => [ :index, :show ]
  
  namespace :home do
    resources :contents
    resources :buttons
    
    match '' => 'dashboard#index', :as => :dashboard
    match 'get-button' => 'dashboard#get_button', :as => :get_button
  end
  
  namespace :admin do
    resources :users, :except => [ :new, :create ]
    match '' => 'dashboard#index', :as => :dashboard
  end
  
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
