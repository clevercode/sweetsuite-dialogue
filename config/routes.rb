SweetSuite::Dialogue::Application.routes.draw do

  root :to => "rooms#index"

  # SweetSuite authentication callback
  match '/auth/sweetsuite/callback' => 'sessions#create'
  match '/auth/failure' => 'sessions#failure'


  resources :rooms

end

