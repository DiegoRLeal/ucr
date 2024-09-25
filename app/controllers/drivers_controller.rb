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

    # Filtra tempos válidos e seleciona a melhor volta de cada piloto, agrupando por car_model, driver_first_name e driver_last_name
    @drivers = Driver.joins('LEFT JOIN car_models ON car_models.car_model = drivers.car_model')
                     .where(track_name: @track_name, session_date: @session_date, session_time: @session_time)
                    #  .where("best_lap::integer < 2147483647")  # Filtra voltas inválidas
                     .select('drivers.car_model, drivers.driver_first_name, drivers.driver_last_name, MIN(best_lap::integer) AS best_lap, MAX(drivers.race_number) AS race_number, MAX(drivers.lap_count) AS lap_count, car_models.car_name, drivers.car_id, drivers.session_date, drivers.session_time')  # Inclui session_date e session_time
                     .group('drivers.car_model, drivers.driver_first_name, drivers.driver_last_name, car_models.car_name, drivers.car_id, drivers.session_date, drivers.session_time')
                     .order(Arel.sql('MIN(best_lap::integer) ASC'))
  end

  def show_lap_times
    @driver = Driver.find_by(driver_first_name: params[:first_name], driver_last_name: params[:last_name], race_number: params[:race_number], session_date: params[:session_date], session_time: params[:session_time])

    if @driver
      # Se 'laps' estiver serializado como string JSON, converta-o para um array
      @laps = @driver.laps.is_a?(String) ? JSON.parse(@driver.laps.gsub('=>', ':')) : @driver.laps

      # Debug: imprime o conteúdo de @laps no log
      puts "Laps content for driver #{@driver.driver_first_name} #{@driver.driver_last_name} on #{params[:session_date]} at #{params[:session_time]}: #{@laps.inspect}"

      # Caso @laps seja nil ou vazio, adicionar uma mensagem de erro
      if @laps.nil? || @laps.empty?
        flash[:alert] = "Nenhuma volta encontrada para o piloto."
      end
    else
      flash[:alert] = "Piloto não encontrado para esta sessão."
      redirect_to drivers_path
    end
  end
end
