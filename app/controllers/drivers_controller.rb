class DriversController < ApplicationController
  include ApplicationHelper  # Incluir o ApplicationHelper para usar format_laptime
  include DriversHelper  # Incluir o ApplicationHelper para usar race

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
    @track_sessions = Driver.select("track_name, session_date, session_time, COUNT(*) as pilots_count")
                        .where(track_name: params[:track_name])
                        .group('track_name, session_date, session_time')
                        .to_a.sort_by { |session| [session.session_date, session.session_time.strftime('%H:%M:%S')] }
                        .reverse
  end

  def show_pilot_times
    @track_name = params[:track_name]
    @session_date = params[:session_date]
    @session_time = params[:session_time]

    race_results = race(@track_name, @session_date, @session_time)

    # Incluindo drivers.total_time na consulta para ser usado na view
    @drivers = Driver.joins('LEFT JOIN car_models ON car_models.car_model = drivers.car_model')
                     .where(track_name: @track_name, session_date: @session_date, session_time: @session_time)
                     .select('drivers.car_model, drivers.driver_first_name, drivers.driver_last_name, drivers.laps, MIN(best_lap::integer) AS best_lap, MAX(drivers.race_number) AS race_number, MAX(drivers.lap_count) AS lap_count, car_models.car_name, drivers.car_id, drivers.total_time, drivers.session_date, drivers.session_time, drivers.penalty_reason, drivers.penalty_type, drivers.penalty_value, drivers.points')
                     .group('drivers.car_model, drivers.driver_first_name, drivers.driver_last_name, drivers.laps, car_models.car_name, drivers.car_id, drivers.total_time, drivers.session_date, drivers.session_time, drivers.penalty_reason, drivers.penalty_type, drivers.penalty_value, drivers.points')
                     .order('MAX(drivers.lap_count) DESC, MIN(best_lap::integer) ASC, MAX(drivers.total_time) ASC')
  end

  def show_lap_times
    @track_name = params[:track_name]
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
