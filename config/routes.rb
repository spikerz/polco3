Polco3::Application.routes.draw do
  resources :votes

  resources :subjects

  resources :rolls

  resources :comments

  resources :polco_groups

  resources :legislator_votes

  resources :legislators

  resources :bills

  root :to => "home#index"
  resources :users, :only => [:index, :show, :edit, :update ]
  match '/auth/:provider/callback' => 'sessions#create'
  match '/signin' => 'sessions#new', :as => :signin
  match '/signout' => 'sessions#destroy', :as => :signout
  match '/auth/failure' => 'sessions#failure'
end
