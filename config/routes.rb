Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Auth routes
      post '/register', to: 'auth#register'
      post '/login', to: 'auth#login'
      get '/me', to: 'auth#me'

      # import in bulk
      resources :assets do
        collection do
          post :bulk_import
        end
      end

      resources :purchases, only: [:index, :create]

      namespace :admin do
        get '/creators/earnings', to: 'creators#earnings'
      end

      get '/creator_earnings', to: 'earnings#creator_earnings'

      get '/purchased_assets', to: 'purchases#purchased_assets'
    end
  end
end
