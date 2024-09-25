class Driver < ApplicationRecord
  belongs_to :car_model, foreign_key: 'car_model', primary_key: 'car_model'

  def lap_times
    return [] unless laps.present?
    # Substitui '=>' por ':' para corrigir o formato JSON antes de fazer o parse
    JSON.parse(laps.gsub('=>', ':'))
  end

  def total_laptime
    lap_times.sum { |lap| lap['laptime'].to_i }
  end

  def average_laptime
    lap_count > 0 ? total_laptime / lap_count : 0
  end

  def penalties
    if penalty_reason.present? || penalty_type.present? || penalty_value.present?
      "#{penalty_reason} - #{penalty_type} (#{penalty_value})"
    else
      "Nenhuma"
    end
  end

  def points
    # Suponha que os pontos sejam baseados em alguma lógica de penalidade ou performance
    base_points = 100
    penalty_deduction = penalty_value.present? ? penalty_value * 10 : 0
    base_points - penalty_deduction
  end
end
