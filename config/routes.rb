Rails.application.routes.draw do
  resources :prices
  resources :products do
    member do
      get 'prices_chart'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
