class DriversController < ApplicationController
  def index
    @tracks = Driver.distinct.order(:track_name).pluck(:track_name)

    # Consulta para pegar o piloto com a melhor volta para cada pista, ignorando voltas inválidas
    @best_laps_by_track = Driver.select('drivers.track_name, drivers.driver_first_name, drivers.driver_last_name, drivers.best_lap')
                                .joins("INNER JOIN (
                                    SELECT track_name, MIN(CAST(best_lap AS INTEGER)) AS best_lap
                                    FROM drivers
                                    WHERE CAST(best_lap AS INTEGER) < 2147483647  -- Filtra os valores inválidos
                                    GROUP BY track_name
                                  ) AS best_laps ON drivers.track_name = best_laps.track_name AND CAST(drivers.best_lap AS INTEGER) = best_laps.best_lap")
                                .order('drivers.track_name')
  end

  def track_sessions
    # Seleciona o nome da pista, data e hora da sessão, número de pilotos
    @track_sessions = Driver.select('track_name, session_date, session_time, COUNT(*) as pilots_count')
                            .where(track_name: params[:track_name])
                            .group('track_name, session_date, session_time')  # Agrupa também por hora da sessão
                            .order('session_date DESC, session_time DESC')  # Ordena por data e hora em ordem decrescente
  end



  def show_pilot_times
    @track_name = params[:track_name]
    @session_date = params[:session_date]
    @session_time = params[:session_time]

    # Depuração
    puts "Track: #{@track_name}, Date: #{@session_date}, Time: #{@session_time}"

    # Filtra tempos válidos e seleciona a melhor volta de cada piloto, agrupando por car_model, driver_first_name e driver_last_name
    @drivers = Driver.joins('LEFT JOIN car_models ON car_models.car_model = drivers.car_model')
                     .where(track_name: @track_name, session_date: @session_date, session_time: @session_time)
                     .where("best_lap::integer < 2147483647")  # Filtra voltas inválidas
                     .select('drivers.car_model, drivers.driver_first_name, drivers.driver_last_name, MIN(best_lap::integer) AS best_lap, MAX(drivers.race_number) AS race_number, MAX(drivers.lap_count) AS lap_count, car_models.car_name, drivers.car_id')
                     .group('drivers.car_model, drivers.driver_first_name, drivers.driver_last_name, car_models.car_name, drivers.car_id')
                     .order(Arel.sql('MIN(best_lap::integer) ASC'))

    # Outra depuração
    puts @drivers.inspect
  end


  def show_lap_times
    @driver = Driver.find_by(car_id: params[:car_id])  # Buscar usando car_id em vez de id

    if @driver
      # Exibir as voltas do piloto
      @laps = @driver.laps  # Adaptar conforme o armazenamento das voltas
    else
      # Tratar o caso onde o piloto não foi encontrado
      flash[:alert] = "Piloto não encontrado."
      redirect_to drivers_path
    end
  end

end
