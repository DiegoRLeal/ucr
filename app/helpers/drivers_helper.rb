module DriversHelper
  include ApplicationHelper  # Incluir o ApplicationHelper para acessar format_laptime

  def calculate_consistency(laps)
    # Converte a string em um hash Ruby, se for necessário
    laps = eval(laps) if laps.is_a?(String)

    # Filtra os tempos de volta válidos
    lap_times = laps.select { |lap| lap['laptime'] && lap['laptime'] > 0 && lap['isValidForBest'] }.map { |lap| lap['laptime'] }

    # Se não houver tempos de volta válidos, a consistência é zero
    return 0 if lap_times.empty?

    # Calcula a média dos tempos de volta
    avg_lap = lap_times.sum.to_f / lap_times.size

    # Calcula o desvio padrão dos tempos de volta
    if lap_times.size > 1
      mean_diff_sum = lap_times.map { |t| (t - avg_lap)**2 }.sum
      std_dev = Math.sqrt(mean_diff_sum / (lap_times.size - 1))
    else
      std_dev = 0
    end

    # Calcula a consistência
    consistency = 1 - (std_dev / avg_lap)

    # Retorna a consistência em termos percentuais
    (consistency * 100).round(2)
  end

  def calculate_points(position)
    points_table = {1 => 25, 2 => 18, 3 => 15, 4 => 12, 5 => 10, 6 => 8, 7 => 6, 8 => 4, 9 => 2, 10 => 1}
    points_table[position] || 0
  end

   # Define o método calculate_avg_lap
  def calculate_avg_lap(driver_laps)
    return 0 if driver_laps.empty?

    # Filtrar apenas as voltas válidas (tempos > 0)
    valid_laps = driver_laps.select { |lap| lap['laptime'] > 0 }

    return 0 if valid_laps.empty?

    # Calcular a média dos tempos de volta
    total_laptime = valid_laps.sum { |lap| lap['laptime'] }
    avg_laptime = total_laptime / valid_laps.size

    avg_laptime
  end

  def process_driver_laps(result)
    if result.laps.present?
      # Substituir '=>' por ':' para transformar em um formato JSON válido e analisar o JSON
      driver_laps = JSON.parse(result.laps.gsub('=>', ':'))

      # Processar os dados de driver_laps como necessário
      driver_laps.each do |lap|
        puts "Lap time: #{lap['laptime']}, Is valid for best lap? #{lap['isValidForBest']}"
      end
    else
      puts "No laps present"
    end
  end

  def calculate_gap(driver, previous_driver)
    # Verificar se o piloto tem voltas ou um tempo total inválido
    return "N/A" if driver.lap_count == 0 || driver.total_time.nil? || driver.total_time.to_i >= 2147483647

    # Se for o primeiro piloto, o gap é zero
    return "0:00.000" if previous_driver.nil?

    driver_total_time = driver.total_time.to_i
    previous_total_time = previous_driver.total_time.to_i

    if driver.lap_count == previous_driver.lap_count
      # Se o número de voltas for o mesmo, calculamos diretamente
      gap = driver_total_time - previous_total_time
    else
      # Se o número de voltas for diferente, calcular o tempo até a mesma volta do piloto anterior
      laps_completed_by_driver = driver.lap_count
      previous_laps = previous_driver.laps.is_a?(String) ? JSON.parse(previous_driver.laps.gsub('=>', ':')) : previous_driver.laps

      if previous_laps.present?
        # Somar os tempos das voltas que o piloto anterior completou até o mesmo número de voltas
        previous_time_for_same_laps = previous_laps[0...laps_completed_by_driver].map { |lap| lap["laptime"].to_i }.sum
        gap = driver_total_time - previous_time_for_same_laps
      else
        return "N/A"
      end
    end

    format_total_laptime(gap)
  end

  def race(track_name, session_date, session_time)
    # Buscar os resultados diretamente da tabela 'drivers'
    results = Driver.where(track_name: track_name, session_date: session_date, session_time: session_time)
                    .order('lap_count DESC, total_time ASC')  # Ordenar por número de voltas e tempo total

    absurd_time_limit = 3_600_000_000

    # Array para armazenar os resultados formatados
    formatted_results = []

    # Preparar os dados formatados para cada resultado
    results.each_with_index do |result, index|
      car_id = result.car_id
      race_number = result.race_number
      driver_first_name = result.driver_first_name
      driver_last_name = result.driver_last_name
      team = result.car_model
      car_model_name = result.car_model
      best_lap = format_laptime(result.best_lap)

      # Substituir '=>' por ':' para transformar em um formato JSON válido
      driver_laps = JSON.parse(result.laps.gsub('=>', ':')) if result.laps.present?

      avg_lap_time = calculate_avg_lap(driver_laps) if driver_laps
      avg_lap = format_laptime(avg_lap_time) if avg_lap_time
      consistency = "#{calculate_consistency(driver_laps)}%" if driver_laps
      total_laps = result.lap_count
      total_time = result.total_time.to_i

      penalties_count = result.penalty_value || 0

      total_time = 0 if total_time >= absurd_time_limit

      # Armazenar os dados formatados em um hash separado
      formatted_results << {
        'race_number' => race_number,
        'driver' => "#{driver_first_name} #{driver_last_name}",
        'team' => team,
        'car_model' => car_model_name,
        'best_lap' => best_lap,
        'avg_lap' => avg_lap,
        'total_laps' => total_laps,
        'total_time' => total_time,
        'formatted_total_time' => format_total_laptime(total_time),
        'consistency' => consistency,
        'penalties' => penalties_count
      }
    end

    # Ordenar resultados com base em total de voltas e tempo total
    sorted_results = formatted_results.sort_by do |r|
      [-r['total_laps'], r['total_time'].positive? ? r['total_time'] : Float::INFINITY]
    end

    # Calcular o gap e posição
    sorted_results.each_with_index do |result, i|
      if result['total_time'] == 0
        result['position'] = ""
        result['gap'] = ""
        result['time'] = ""
      else
        if i == 0
          result['gap'] = "0.000"
          result['time'] = result['formatted_total_time']
        else
          gap = result['total_time'] - sorted_results[i - 1]['total_time']
          result['gap'] = format_total_laptime(gap)
          result['time'] = result['formatted_total_time']
        end
        result['position'] = i + 1
      end

      result['points'] = calculate_points(result['position'])
    end

    sorted_results
  end
end
