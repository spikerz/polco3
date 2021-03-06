Polco3::Application.routes.draw do

  resources :roles

  get "home/polco_info"

  resources :rolls do
    resources :comments
  end

  resources :bills do
    resources :comments
  end

  resources :legislators do
    resources :comments
  end

  resources :subjects

  # sign up a user for a district
  match "/users/geocode" => "users#geocode"
  match "/users/save_geocode" => "users#save_geocode"
  match "/users/district" => "users#district"

  get "polco_groups/add_custom_group"
  post "polco_groups/follow_group"
  post "polco_groups/join_group"

  resources :polco_groups do
    resources :comments
  end

  resources :legislator_votes # necessary?
  resources :votes

  resources :identities

  # what bills are active?
  get "represent/house_bills"
  get "represent/senate_bills"
  # how are the legislators voting?
  get "represent/legislators_districts"
  get "represent/states"
  # how are you being represented?
  # H3. and S3 house results -- how represented are you in the house?
  match "/represent/:chamber" => "represent#results", as: :results
  # helper to add vote
  post "rolls/add_vote", as: :add_vote

  root to: "represent#house_bills"
  resources :users, :only => [:index, :show, :edit, :update ] do
    resources :comments
  end

  match '/auth/:provider/callback', to: 'sessions#create'
  match '/signin', to: 'sessions#new', as: :signin
  match '/signout', to: 'sessions#destroy', as: :signout
  match '/auth/failure', to: 'sessions#failure'
end
