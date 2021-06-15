Rails.application.routes.draw do

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, :at => '/'
          # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  Spree::Core::Engine.routes.draw do

    namespace :api, defaults: { format: 'json' } do
      resources :vendors , only: [:create, :index]
      resources :salesmen , only: [:index]
      resources :timestamp , only: [:index] 
      get 'products/stock_quantity' => 'products#stock_quantity'
      get 'products/product_prices' => 'products#product_prices'
      patch '/stock_items/update_multiple' => 'stock_items#update_multiple'
      post 'vendor_visit' => "vendors#vendor_visit"
      
      # To list taxon's products in Taxons index page.
      get '/taxons/products', to: 'taxons#products'
      get '/taxons/siblings', to: 'taxons#siblings'
      get '/taxons/sub_category_list', to: 'taxons#sub_category_list'
      get '/taxonomies/siblings', to: 'taxonomies#siblings'
      get '/users/vendor', to: 'users#getvendor'
      resources :taxons, only: [:index, :show]
      resources :racks, only: [:index] 
    end

    get 'custom_importer/import_products'
    post 'custom_importer/import_products'
    get 'custom_importer/list_product_details'
    post 'custom_importer/list_product_details'
   
    resource :vendor, only: [:vendors] do
      get '' => 'vendor#index'
      get 'index' => 'vendor#index'
      get 'select' => "vendor#select_vendor"
      post 'select' => "vendor#select_vendor"
      get 'add' => "vendor#add_vendor"
      post 'add' => "vendor#add_vendor"
      get 'reports' => "vendor#view_reports"
      post 'reports' => "vendor#view_reports"
      get 'login' => "vendor#login"
      post 'login' => "vendor#login"
    end
    
    namespace :admin do

      resources :users do 
        resources :vendor_payments
      end

      resources :racks do
      end

      resources :taxonomies do
        get :category_tree
        post :category_tree
        resources :taxons do
          get :sub_category_tree
          #post :sub_category_tree

          resources :taxon_prices do
          end
          resources :products, controller: 'taxons' do
            member do
              get :edit_product
              post :update_product
            end
          end
        end
      end
  
      resources :taxons, only: [:index, :show] do
        collection do
          get :new_item
          post :new_item
          get :new_sub_category
          post :new_sub_category
        end
        member do 
          get :edit_new_item
          patch :update_new_item
          get :new_product
          post :new_product
          get :new_multiple_product
          post :new_multiple_product
          get :edit_product
          put :update_product
          patch :update_product
          get :get_product_names
          post :delete_multiple_products
        end
      end
  
      resources :reports, only: [:index] do
        collection do
          get :visit
          post :visit
          get :product_stock_history
          post :product_stock_history
          get :product_price_history
          post :product_price_history
          get :order
          post :order
          get :rack_stock
          post :rack_stock
        end
      end

      get '/taxon_prices/taxon_details' => 'taxon_prices#taxon_details'
      post '/taxon_prices/taxon_details' => 'taxon_prices#taxon_details'
      post 'orders/cancel_multiple_orders' => 'orders#cancel_multiple_orders'
    end
    post '/currency/set' => 'currency#set'
  end
  post '/contact_us/send_email' => 'contact_us#send_email'
end
