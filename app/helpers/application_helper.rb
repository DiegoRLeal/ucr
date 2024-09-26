module ApplicationHelper
  def format_laptime(laptime)
    # Certifique-se de que o laptime é um número inteiro
    laptime = laptime.to_i

    # Verificar se o tempo de volta é inválido
    return "N/A" if laptime.nil? || laptime <= 0

    # Converter milissegundos para minutos e segundos
    minutes = laptime / 60000
    seconds = (laptime % 60000) / 1000.0

    # Formatar o tempo como "m:ss.sss"
    format("%d:%02d.%03d", minutes, seconds.floor, (seconds.modulo(1) * 1000).round)
  end


  def format_total_laptime(laptime)
    # Verificar se o tempo é inválido (muito grande) ou nulo
    return "N/A" if laptime.nil? || laptime >= 2147483647

    minutes = laptime / 60000
    remaining_ms = laptime % 60000
    seconds = remaining_ms / 1000
    milliseconds = remaining_ms % 1000

    format("%d:%02d.%03d", minutes, seconds, milliseconds)
  end


  def format_track_name(track_name)
    track_name.split('_').map(&:capitalize).join(' ')
  end
end
