Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'boards#index'
  resources :boards, only: [:show, :index, :new, :create] do
    resources :reservations
  end
end
