RailsAdmin.config do |config|
  config.asset_source = :sprockets

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)
    config.authenticate_with do
      warden.authenticate! scope: :user
    end
    config.current_user_method(&:current_user)

    config.authorize_with do
      unless current_user.admin?
        flash[:alert] = 'Sorry, no admin access for you.'
        redirect_to main_app.root_path
      end
    end

    config.model 'Pilot' do
      label 'Drivers'  # Isso vai alterar o nome exibido no menu para 'Drivers'
      list do
        field :name
        field :instagram
        field :twitch
        field :youtube
        field :categoria
      end

      edit do
        field :name
        field :instagram
        field :twitch
        field :youtube
        field :image_url
        field :categoria, :enum do
          enum do
            ['PRO', 'SILVER', 'AM']
          end
        end
      end

      show do
        field :name
        field :instagram
        field :twitch
        field :youtube
        field :categoria
      end
    end

    config.model 'Driver' do
      label 'Race Results'  # Renomeia para 'Race Results'

      list do
        field :car_id
        field :race_number
        field :car_model
        field :driver_first_name
        field :driver_last_name
        field :best_lap
        field :total_time
        field :lap_count
        field :track_name
        field :session_date
        field :session_type
      end

      edit do
        field :car_id
        field :race_number
        field :car_model
        field :driver_first_name
        field :driver_last_name
        field :best_lap
        field :total_time
        field :lap_count
        field :track_name
        field :session_date
        field :session_time
        field :session_type
        field :laps, :json  # Exibe o campo 'laps' como JSON no formulário de edição
      end

      show do
        field :car_id
        field :race_number
        field :car_model
        field :driver_first_name
        field :driver_last_name
        field :best_lap
        field :total_time
        field :lap_count
        field :track_name
        field :session_date
        field :session_time
        field :session_type
        field :laps, :json  # Exibe o campo 'laps' como JSON no modo de exibição
      end
    end

    config.model 'Sponsor' do
      list do
        field :nome
        field :image_url
      end
      edit do
        field :nome
        field :image_url
      end
    end

    config.model 'Track' do
      list do
        field :track_id
        field :track_name
        field :created_at
        field :updated_at
      end

      edit do
        field :track_id
        field :track_name
      end

      show do
        field :track_id
        field :track_name
        field :created_at
        field :updated_at
      end
    end


    # config.included_models = [ "Seller", "Product", "User" ]

  ## == CancanCan ==
  # config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/railsadminteam/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
