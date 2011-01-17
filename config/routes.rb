SweetSuite::Dialogue::Application.routes.draw do
  match "/auth/sweetsuite/callback" => "sessions#create"
  root :to => "home#index"

  match "/talk" => TalkController
end
