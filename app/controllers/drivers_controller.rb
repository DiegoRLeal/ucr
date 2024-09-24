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
    @track_sessions = Driver.select('track_name, session_date, COUNT(*) as pilots_count')
                            .where(track_name: params[:track_name])
                            .group('track_name, session_date')
                            .order('session_date DESC')  # Ordena por data em ordem decrescente
  end

  def show_pilot_times
    @track_name = params[:track_name]
    @session_date = params[:session_date]

    # Filtra tempos inválidos e converte 'best_lap' para número, ordenando corretamente
    @drivers = Driver.where(track_name: @track_name, session_date: @session_date)
                     .where("CAST(best_lap AS INTEGER) < 2147483647")  # Ignora voltas inválidas
                     .order(Arel.sql('CAST(best_lap AS INTEGER) ASC'))  # Usa Arel.sql para SQL bruto
  end


  def show_lap_times
    @driver = Driver.find(params[:id])
    # Aqui você terá que adaptar para onde estão armazenadas todas as voltas de um piloto.
    # Se as voltas não estiverem no Driver, você terá que acessar a tabela onde as voltas estão armazenadas.
  end
end
