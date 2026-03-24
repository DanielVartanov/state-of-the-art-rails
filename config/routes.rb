Rails.application.routes.draw do
  resources :messages, only: %i[index create]
  resources :users, only: %i[index create]

  root "users#index"
end
