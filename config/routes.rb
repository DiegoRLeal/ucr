Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "mains#index"

  get "sobre_nos", to: 'mains#sobre_nos', as: 'sobre_nos'
  get "pilotos", to: 'mains#pilotos', as: 'pilotos'
  get "campeonatos", to: 'mains#campeonatos', as: 'campeonatos'
  get "fale_conosco", to: 'mains#fale_conosco', as: 'fale_conosco'
  get "patrocinadores", to: 'mains#patrocinadores', as: 'patrocinadores'
  get "results", to: 'mains#results', as: 'results'
end
