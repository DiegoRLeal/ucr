Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: { registrations: 'registrations' }

  authenticate :user, ->(user) { user.admin? } do
    mount Blazer::Engine, at: "blazer"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "mains#index"

  get "campeonatos", to: 'mains#campeonatos', as: 'campeonatos'
  get "patrocinio", to: 'mains#patrocinio', as: 'patrocinio'
  get "pilotos", to: 'mains#pilotos', as: 'pilotos'
  get "resultados", to: 'mains#resultados', as: 'resultados'
  # get "carros", to: 'mains#carros', as: 'carros'
  get "setups", to: 'mains#setups', as: 'setups'
  # get "contato", to: 'mains#contato', as: 'contato'
  get "sidebar", to: 'mains#sidebar', as: 'sidebar'

  # PWA
  get '/offline', to: 'pages#offline', as: 'offline'
  get '/service-worker.js' => 'service_workers#service_worker'

  # JOB DE BUSCAR OS JSON NO DRIVE
  get '/oauth2callback', to: 'mains#oauth2callback'
  get 'job', to: 'mains#job'
  # get '/show_specific_json', to: 'mains#show_specific_json'

  resources :drivers, only: [:index] do
    collection do
      get 'show_pilot_times'
      get 'show_lap_times'
      get 'track_sessions'
    end
  end
end
