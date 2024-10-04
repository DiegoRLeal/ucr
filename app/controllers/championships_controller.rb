class ChampionshipsController < ApplicationController
  include ApplicationHelper  # Incluir o ApplicationHelper para usar format_laptime
  include DriversHelper  # Incluir o ApplicationHelper para usar race

  def index
    @tracks = Championship.distinct.order(:track_name).pluck(:track_name)

    # Consulta para pegar o piloto com a melhor volta para cada pista, ignorando voltas inválidas
    @best_laps_by_track = Championship.select('championships.track_name, championships.driver_first_name, championships.driver_last_name, championships.best_lap')
                                .joins("INNER JOIN (
                                    SELECT track_name, MIN(CAST(best_lap AS INTEGER)) AS best_lap
                                    FROM championships
                                    WHERE CAST(best_lap AS INTEGER) < 2147483647  -- Filtra os valores inválidos
                                    GROUP BY track_name
                                  ) AS best_laps ON championships.track_name = best_laps.track_name AND CAST(championships.best_lap AS INTEGER) = best_laps.best_lap")
                                .order('championships.track_name')
  end

  def track_sessions
    # Seleciona o nome da pista, data e hora da sessão, número de pilotos
    @track_sessions = Championship.select('track_name, session_date, session_time, COUNT(*) as pilots_count')
                            .where(track_name: params[:track_name])
                            .group('track_name, session_date, session_time')  # Agrupa também por hora da sessão
                            .order('session_date DESC, session_time DESC')  # Ordena por data e hora em ordem decrescente
  end

  def show_pilot_times
    @track_name = params[:track_name]
    @session_date = params[:session_date]
    @session_time = params[:session_time]

    race_results = race(@track_name, @session_date, @session_time)

    # Incluindo championships.total_time e penalty_points na consulta para serem usados na view
    @drivers = Championship.joins('LEFT JOIN car_models ON car_models.car_model = championships.car_model')
                           .where(track_name: @track_name, session_date: @session_date, session_time: @session_time)
                           .select('championships.id, championships.car_model, championships.driver_first_name, championships.driver_last_name, championships.laps, MIN(best_lap::integer) AS best_lap, MAX(championships.race_number) AS race_number, MAX(championships.lap_count) AS lap_count, car_models.car_name, championships.car_id, championships.total_time, championships.session_date, championships.session_time, championships.penalty_reason, championships.penalty_type, championships.penalty_value, championships.penalty_points, championships.points') # Adicionando penalty_points
                           .group('championships.id, championships.car_model, championships.driver_first_name, championships.driver_last_name, championships.laps, car_models.car_name, championships.car_id, championships.total_time, championships.session_date, championships.session_time, championships.penalty_reason, championships.penalty_type, championships.penalty_value, championships.penalty_points, championships.points') # Adicionando penalty_points no group
                           .order('MAX(championships.lap_count) DESC, MIN(best_lap::integer) ASC, MAX(championships.total_time) ASC')
  end

  def show_lap_times
    @track_name = params[:track_name]
    @drivers = Championship.find_by(driver_first_name: params[:first_name], driver_last_name: params[:last_name], race_number: params[:race_number], session_date: params[:session_date], session_time: params[:session_time])

    if @driver
      # Se 'laps' estiver serializado como string JSON, converta-o para um array
      @laps = @driver.laps.is_a?(String) ? JSON.parse(@driver.laps.gsub('=>', ':')) : @driver.laps

      # Debug: imprime o conteúdo de @laps no log
      puts "Laps content for championship #{@driver.driver_first_name} #{@driver.driver_last_name} on #{params[:session_date]} at #{params[:session_time]}: #{@laps.inspect}"

      # Caso @laps seja nil ou vazio, adicionar uma mensagem de erro
      if @laps.nil? || @laps.empty?
        flash[:alert] = "Nenhuma volta encontrada para o piloto."
      end
    else
      flash[:alert] = "Piloto não encontrado para esta sessão."
      redirect_to championships_path
    end
  end

  # Lista todos os pilotos de uma determinada corrida para aplicar penalidades
  def penalties
    @championship = Championship.find(params[:id])

    # Seleciona todos os pilotos dessa corrida (session_date e session_time)
    @drivers = Championship.where(track_name: @championship.track_name, session_date: @championship.session_date, session_time: @championship.session_time)
  end

  # Aplica as penalidades aos pilotos selecionados
  def apply_penalties
    drivers = Championship.where(track_name: params[:track_name], session_date: params[:session_date], session_time: params[:session_time])

    drivers.each do |driver|
      penalty_params = params[:penalties][driver.id.to_s]

      # Verifica se `penalty_value` é fornecido ou se deseja limpar o campo
      penalty_value = penalty_params[:penalty_value].presence
      penalty_points = penalty_params[:penalty_points].presence

      # Atualiza os valores de penalidades, incluindo `penalty_value` e `penalty_points`
      driver.update(
        penalty_reason: penalty_params[:penalty_reason],
        penalty_type: penalty_params[:penalty_type],
        penalty_value: penalty_value, # Atualizando corretamente o penalty_value
        penalty_violation_in_lap: penalty_params[:penalty_violation_in_lap],
        penalty_cleared_in_lap: penalty_params[:penalty_cleared_in_lap],
        penalty_points: penalty_points # Aplicando os pontos de penalidade
      )
    end

    # flash[:notice] = "Penalidades aplicadas com sucesso."

    # Redireciona para a página com os tempos dos pilotos já atualizados
    redirect_to show_pilot_times_championships_path(track_name: params[:track_name], session_date: params[:session_date], session_time: params[:session_time])
  end

  private

  def penalty_params
    params.require(:championship).permit(:penalty_reason, :penalty_type, :penalty_value, :penalty_violation_in_lap, :penalty_cleared_in_lap)
  end
end
