Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users

  get 'profile/edit', to: 'users#edit', as: :edit_profile
  patch 'profile', to: 'users#update', as: :update_profile

  authenticate :user, ->(user) { user.admin? } do
    mount Blazer::Engine, at: "blazer"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "mains#index"

  get "resultados", to: 'mains#resultados', as: 'resultados'
  get "campeonatos", to: 'mains#campeonatos', as: 'campeonatos'
  get "pilotos", to: 'mains#pilotos', as: 'pilotos'
  get "carros", to: 'mains#carros', as: 'carros'
  get "patrocinio", to: 'mains#patrocinio', as: 'patrocinio'
  get "setups", to: 'mains#setups', as: 'setups'
  get "contato", to: 'mains#contato', as: 'contato'
end
