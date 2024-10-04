RailsAdmin.config do |config|
  config.asset_source = :sprockets

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
    label 'Driver'   # Exibe 'Driver' no singular
    label_plural 'Drivers'  # Exibe 'Drivers' no plural
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
      field :car_model do
        pretty_value do
          bindings[:object].car_model.car_name  # Exibe o nome do carro corretamente na listagem
        end
      end
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
      field :car_model do
        label "Modelo do Carro"
        associated_collection_scope do
          Proc.new { |scope|
            scope.reorder('car_name ASC')  # Ordena por car_name
          }
        end

        # Exibe car_name diretamente na dropdown
        pretty_value do
          bindings[:object].car_model.car_name  # Exibe o nome do carro na edição
        end
      end
      field :driver_first_name
      field :driver_last_name
      field :best_lap
      field :total_time
      field :lap_count
      field :track_name
      field :session_date
      field :session_time
      field :session_type
      field :laps, :json
    end

    show do
      field :car_id
      field :race_number
      field :car_model do
        pretty_value do
          bindings[:object].car_model.car_name  # Exibe o nome correto no modo de exibição
        end
      end
      field :driver_first_name
      field :driver_last_name
      field :best_lap
      field :total_time
      field :lap_count
      field :track_name
      field :session_date
      field :session_time
      field :session_type
      field :laps, :json
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

    object_label_method :track_name
  end

  config.model 'RaceDay' do
    list do
      field :date
      field :track do
        pretty_value do
          bindings[:object].track.track_name  # Exibe o track_name na listagem
        end
      end
      field :max_pilots
    end

    edit do
      field :date

      field :track do
        label "Pista"

        associated_collection_scope do
          Proc.new { |scope|
            scope.select(:id, :track_name)  # Seleciona explicitamente o track_name para a dropdown
          }
        end

        help "Escolha a pista"
      end

      field :max_pilots
    end

    object_label_method :to_s
  end

  config.model 'PilotRegistration' do
    list do
      field :pilot_name
      field :race_day
      field :car_number do
        pretty_value do
          bindings[:object].car_number.number  # Exibe o track_name na listagem
        end
      end
    end

    edit do
      field :pilot_name
      field :race_day
      field :car_number
    end
  end

  config.model 'CarNumber' do
    list do
      # field :number
      field :race_day
    end

    edit do
      # O campo 'number' será uma enumeração de números de 1 a 999
      field :number, :enum do
        enum do
          (1..999).map { |n| [n, n] }  # Gera uma lista de números de 1 a 999
        end
        label "Número do Carro"
      end

      field :race_day do
        label "Dia de Corrida"
      end
    end
  end

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
  end
end
