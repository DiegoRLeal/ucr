class DriversController < ApplicationController
  def index
    @track_sessions = Driver.select('track_name, session_date, COUNT(*) as pilots_count')
                            .group('track_name, session_date')
                            .order('session_date DESC')
  end

  def show_pilot_times
    @track_name = params[:track_name]
    @session_date = params[:session_date]

    # Lógica para buscar os pilotos baseados na pista e data da sessão
    @drivers = Driver.where(track_name: @track_name, session_date: @session_date)

    # Renderizar a view que exibe os tempos dos pilotos
  end

  def show_lap_times
    @driver = Driver.find(params[:id])
    # Aqui você terá que adaptar para onde estão armazenadas todas as voltas de um piloto.
    # Se as voltas não estiverem no Driver, você terá que acessar a tabela onde as voltas estão armazenadas.
  end
end
