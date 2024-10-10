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
    # Conta apenas razões de penalidade válidas
    reason_count = penalty_reason.is_a?(Array) ? penalty_reason.reject(&:blank?).size : 0

    # Conta apenas pontos de penalidade válidos
    points_count = penalty_points.is_a?(Array) ? penalty_points.reject { |p| p.blank? || p.to_i == 0 }.size : 0

    # Retorna o maior valor entre os dois (razões ou pontos de penalidade)
    [reason_count, points_count].max
  end
end
