Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "/", to: "welcome#index"


  resources :merchants do
    resources :items, only: [:index, :new, :create]
  end

  resources :items do
    resources :reviews
  end

  resources :reviews, only: [:edit, :update, :destroy]

  post "/cart/:item_id", to: "cart#add_item"
  get "/cart", to: "cart#show"
  delete "/cart", to: "cart#empty"
  delete "/cart/:item_id", to: "cart#remove_item"
  patch "/cart/:item_id/add_quantity", to: "cart#add_quantity"
  patch "/cart/:item_id/decrease-quantity", to: "cart#decrease_quantity"

  resources :orders, only: [:new, :create, :show, :destroy] do
      patch "/ship", to: "orders#ship", as: 'ship'
  end

  resources :users, only: [:new], path_names: {new: "/register"}

  resources :users, only: [:new, :create]

  resources :profile, except: [:show] do
    get "/admin", to: "profile#index"
  end

  resources :password

  resources :login, :controller => 'sessions', only: [:create]
  get "/login", to: "sessions#new"

  get "profile/orders", to: "profile_orders#index"
  get "profile/orders/:id", to: "profile_orders#show"


  namespace :merchant do
    resources :items, only: [:new, :create, :edit, :update, :destroy, :index]
    root "dashboard#index"
    resources :dashboard, only: [:index]
    resources :orders, only: [:show]
    resources :items, only: [:update] do
      resources :orders, only: [:update]
    end
  end

  namespace :admin do
    resources :users, only: [:index, :show]
    root "dashboard#show"
    get "/profile", to: "profile#index"
    get "/merchants", to: "merchant#index"
    patch "/merchants/:id/update", to: "merchant#update"
    get "/merchants/:merchant_id/items", to: "items#index"
    delete "/merchants/:merchant_id/items/:item_id", to: "items#destroy"
    post "/merchants/:merchant_id/items", to: 'items#create'
    get "/merchants/:merchant_id/items/new", to: "items#new"
    get "/merchants/:merchant_id/items/:item_id/edit", to: 'items#edit'
    patch "/merchants/:merchant_id/items/:item_id", to: "items#update"
    get "/merchants/:id", to: "merchant#show"
    get "/dashboard", to: "dashboard#show"
  end

  resources :logout, only: [:index]
end
