Rails.application.routes.draw do
  root "games#index"
  get 'about' => 'about#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'

  get '/auth/failure' do
    flash[:notice] = params[:message]
    redirect '/'
  end

  resources :games do
    resources :pickups
    resources :rounds
    resources :actions, only: :index
  end
end
