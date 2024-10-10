class ChampionshipsController < ApplicationController
  include ApplicationHelper  # Incluir o ApplicationHelper para usar format_laptime
  include DriversHelper  # Incluir o ApplicationHelper para usar race
  before_action :set_championship, only: [:edit, :update, :add_penalty, :apply_penalties, :destroy]

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

    # Incluindo championships.total_time, penalty_points e cup_category na consulta para serem usados na view
    @drivers = Championship.joins('LEFT JOIN car_models ON car_models.car_model = championships.car_model')
                           .where(track_name: @track_name, session_date: @session_date, session_time: @session_time)
                           .select('championships.id, championships.car_model, championships.driver_first_name, championships.driver_last_name, championships.laps, MIN(best_lap::integer) AS best_lap, MAX(championships.race_number) AS race_number, MAX(championships.lap_count) AS lap_count, car_models.car_name, championships.car_id, championships.total_time, championships.session_date, championships.session_time, championships.penalty_reason, championships.penalty_type, championships.penalty_value, championships.penalty_points, championships.points, championships.cup_category') # Adicionando cup_category
                           .group('championships.id, championships.car_model, championships.driver_first_name, championships.driver_last_name, championships.laps, car_models.car_name, championships.car_id, championships.total_time, championships.session_date, championships.session_time, championships.penalty_reason, championships.penalty_type, championships.penalty_value, championships.penalty_points, championships.points, championships.cup_category') # Adicionando cup_category no group
                           .order('MAX(championships.lap_count) DESC, MIN(best_lap::integer) ASC, MAX(championships.total_time) ASC')
  end

  def show_lap_times
    @track_name = params[:track_name]
    @driver = Championship.find_by(driver_first_name: params[:first_name], driver_last_name: params[:last_name], race_number: params[:race_number], session_date: params[:session_date], session_time: params[:session_time])

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
    @driver = Championship.find_by(id: params[:id])

    # Seleciona todos os pilotos dessa corrida (session_date e session_time)
    @drivers = Championship.where(track_name: @championship.track_name, session_date: @championship.session_date, session_time: @championship.session_time)
  end

  def add_penalty
    # Adicionando uma nova penalidade
    @championship.penalty_reason << "Nova Penalidade"
    @championship.penalty_value << 5
    @championship.penalty_violation_in_lap << 3
    @championship.penalty_cleared_in_lap << 5
    @championship.penalty_points = [@championship.penalty_points, "10"].compact.join(',')

    if @championship.save
      redirect_to edit_championship_path(@championship), notice: 'Penalidade adicionada com sucesso.'
    else
      render :edit
    end
  end

  def apply_penalties
    championship = Championship.find(params[:id])

    # Adiciona novas penalidades via parâmetros (penalty_points vindo do formulário)
    if params[:championship][:penalty_points].present?
      new_penalty_points = params[:championship][:penalty_points].map(&:to_i)

      # Atualiza o campo penalty_points removendo nil e somando as novas penalidades
      championship.penalty_points ||= []
      championship.penalty_points = (championship.penalty_points.compact + new_penalty_points).reject(&:nil?)
    end

    if championship.save
      flash[:success] = "Penalidades aplicadas com sucesso!"
    else
      flash[:error] = "Erro ao aplicar penalidades."
    end

    redirect_to penalties_championship_path(championship)
  end

  def new
    @championship = Championship.new
  end

  def edit
  end

  def update
    if params[:championship].present?
      puts params[:championship] # Isso ajuda a verificar os parâmetros no log

      if @championship.update(championship_params)
        redirect_to show_pilot_times_championships_path(session_date: @championship.session_date, session_time: @championship.session_time, track_name: @championship.track_name), notice: 'Campeonato atualizado com sucesso.'
      else
        render :edit
      end
    else
      # Se não houver parâmetros de campeonato, remove todas as penalidades
      @championship.update(penalty_reason: [], penalty_type: [], penalty_value: [], penalty_violation_in_lap: [], penalty_cleared_in_lap: [], penalty_points: [])
      redirect_to show_pilot_times_championships_path(session_date: @championship.session_date, session_time: @championship.session_time, track_name: @championship.track_name), notice: 'Todas as penalidades foram removidas.'
    end
  end

  def destroy
    @championship.destroy
    redirect_to championships_url, notice: 'Campeonato deletado com sucesso.'
  end

  private

  def set_championship
    @championship = Championship.find(params[:id])
  end

  def championship_params
    params.require(:championship).permit(
      penalty_reason: [],
      penalty_type: [],
      penalty_value: [],
      penalty_violation_in_lap: [],
      penalty_cleared_in_lap: [],
      penalty_points: []
    )
  end
end
