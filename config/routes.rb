Ispace::Application.routes.draw do

  resources :plan_sets
  resources :plans

  devise_for :users
  devise_scope :user do
    get "sign_in" => "devise/sessions#new", as: :sign_in
    delete "sign_out" => "devise/sessions#destroy", as: :sign_out
  end

  resources :users
  resources :sales

  get "mdses/" => "mdses#index"
  resources :brands
  resources :suppliers
  resources :manufacturers
  resources :products
  patch "products/" => "products#update_ex"
  resources :import_sheets

  resources :fixtures
  resources :stores
  resources :regions, except: [:patch]
  patch "regions/*id", to: "regions#update", defaults: { format: 'js' }

  # removed resources
  # resources :fixture_items
  # resources :rear_support_bars
  # resources :freezer_chests
  # resources :peg_boards
  # resources :open_shelves

  resources :bays

  get "categories/manage"
  post "categories/bulk_update"
  resources :categories

  root 'stores#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
