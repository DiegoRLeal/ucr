class DriversController < ApplicationController
  def index
    @tracks = Driver.distinct.order(:track_name).pluck(:track_name)
    @best_laps_by_track = Driver.group(:track_name).minimum(:best_lap)
  end

  def track_sessions
    @track_sessions = Driver.select('track_name, session_date, COUNT(*) as pilots_count')
                            .where(track_name: params[:track_name])
                            .group('track_name, session_date')
                            .order('session_date DESC')  # Ordena por data em ordem decrescente
  end

  def show_pilot_times
    @track_name = params[:track_name]
    @session_date = params[:session_date]

    # Ordena os pilotos pela melhor volta (best_lap) em ordem crescente
    @drivers = Driver.where(track_name: @track_name, session_date: @session_date)
                     .order('best_lap ASC')
  end

  def show_lap_times
    @driver = Driver.find(params[:id])
    # Aqui você terá que adaptar para onde estão armazenadas todas as voltas de um piloto.
    # Se as voltas não estiverem no Driver, você terá que acessar a tabela onde as voltas estão armazenadas.
  end
end
