Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post '/auth/sign_up', to: 'auth#sign_up'
      post '/auth/sign_in', to: 'auth#sign_in'
      delete '/auth/sign_out', to: 'auth#sign_out'

      get '/files', to: 'uploads#index'
      post '/files', to: 'uploads#create'
      delete '/files/:idx', to: 'uploads#delete'
    end
  end
end
