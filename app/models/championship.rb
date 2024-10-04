class Championship < ApplicationRecord
  belongs_to :car_model, foreign_key: 'car_model', primary_key: 'car_model'
  # belongs_to :track
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

  def penalties
    if penalty_reason.present? || penalty_type.present? || penalty_value.present?
      "#{penalty_reason} - #{penalty_type} (#{penalty_value})"
    else
      "0"
    end
  end
end
