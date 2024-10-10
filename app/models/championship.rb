class Championship < ApplicationRecord
  belongs_to :car_model, foreign_key: 'car_model', primary_key: 'car_model'
  belongs_to :track, foreign_key: :track_name, primary_key: :track_name, optional: true

  def lap_times
    # Verifica se laps está presente e converte o JSON corretamente
    laps.present? ? JSON.parse(laps.gsub('=>', ':')) : []
  end

  def total_laptime
    lap_times.sum { |lap| lap['laptime'].to_i }
  end

  def average_laptime
    lap_count > 0 ? total_laptime / lap_count : 0
  end

  def total_penalties
    # Verifica se penalty_points é um array e conta o número de elementos, incluindo nil
    penalty_points.is_a?(Array) ? penalty_points.length : 0
  end
end
