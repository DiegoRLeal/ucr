module ApplicationHelper
  def format_laptime(laptime)
    # Definir um limite razoável para uma volta, como 10 minutos (600.000 ms)
    max_valid_time = 10 * 60 * 1000  # 10 minutos em milissegundos

    # Verificar se o tempo de volta é inválido ou irrealisticamente alto
    return "N/A" if laptime.nil? || laptime <= 0 || laptime >= max_valid_time

    # Converter milissegundos para minutos e segundos
    minutes = laptime / 60000
    seconds = (laptime % 60000) / 1000.0

    # Formatar o tempo como "m:ss.sss"
    format("%d:%06.3f", minutes, seconds)
  end

  def format_total_laptime(laptime)
    return "N/A" if laptime.nil? || laptime <= 0

    minutes = laptime / 60000
    seconds = (laptime % 60000) / 1000.0

    format("%d:%06.3f", minutes, seconds)
  end

  def format_track_name(track_name)
    track_name.split('_').map(&:capitalize).join(' ')
  end

  def points(position, penalty_value = 0)
    base_points = case position
    when 1 then 40
    when 2 then 37
    when 3 then 34
    when 4 then 31
    when 5 then 28
    when 6 then 26
    when 7 then 24
    when 8 then 22
    when 9 then 20
    when 10 then 18
    when 11 then 17
    when 12 then 16
    when 13 then 15
    when 14 then 14
    when 15 then 13
    else 0
    end

    penalty_deduction = penalty_value * 10
    total_points = base_points - penalty_deduction
    total_points > 0 ? total_points : 0
  end
end
