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


  def format_track_name(track_name)
    track_name.split('_').map(&:capitalize).join(' ')
  end
end
