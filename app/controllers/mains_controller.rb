require "google/apis/drive_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require "json"

class MainsController < ApplicationController
  # before_action :authenticate_user!, only: [:sidebar]

  OOB_URI = "http://localhost:3000/job/oauth2callback".freeze
  APPLICATION_NAME = "Google Drive API Ruby".freeze
  TOKEN_PATH = "token.yaml".freeze
  SCOPE = Google::Apis::DriveV3::AUTH_DRIVE

  # Método de autorização
  def authorize
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = "default"
    credentials = authorizer.get_credentials(user_id)

    # Se as credenciais não forem encontradas ou expiraram, redirecionar para login
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      return redirect_to url, allow_other_host: true
    elsif credentials.expired? && credentials.refresh_token
      begin
        credentials.refresh!  # Renova o token se o refresh token estiver presente
      rescue Signet::AuthorizationError => e
        if e.message.include?("invalid_grant")
          # O refresh token foi revogado ou expirou, redireciona para uma nova autorização
          flash[:error] = "Token expirado ou revogado. É necessário fazer login novamente."
          token_store.delete(user_id)  # Remove o token inválido do armazenamento
          url = authorizer.get_authorization_url(base_url: OOB_URI)
          return redirect_to url, allow_other_host: true
        else
          raise e  # Lança outro erro se não for um problema com o token
        end
      end
    end

    # Retornar as credenciais para serem usadas no serviço do Google Drive
    credentials
  end

  def resultados
    @pilots = Pilot.all # ou algum filtro específico, como Pilot.where(...)
  end

  def extract_season_and_year_from_server_name(server_name)
    season = if server_name.match?(/1st Season/i)
               "1st Season"
             elsif server_name.match?(/2nd Season/i)
               "2nd Season"
             elsif server_name.match?(/3rd Season/i)
               "3rd Season"
             else
               "Unknown Season"
             end

    # Extrair o ano, assumindo que o serverName contém um ano em formato de 4 dígitos
    year_match = server_name.match(/(\d{4})/)
    year = year_match ? year_match[1].to_i : nil

    { season: season, year: year }
  end

  def job
    log_file = File.open("processamento_pilotos_detalhado.log", "a")

    # Inicializar o serviço Google Drive
    drive_service = Google::Apis::DriveV3::DriveService.new
    drive_service.client_options.application_name = APPLICATION_NAME
    drive_service.authorization = authorize

    folder_id = '1n4QWdy3GvOgeuweeSulr03BNtAcEXAHY' # ID da pasta no Google Drive do Server
    page_token = nil
    max_files = nil  # Definir a quantidade máxima de arquivos (nil para processar todos)
    processed_count = 0

    begin
      loop do
        query = "'#{folder_id}' in parents and mimeType='application/json'"
        response = drive_service.list_files(q: query, page_size: 100, fields: "nextPageToken, files(id, name)", page_token: page_token)

        if response.files.empty?
          puts "Nenhum arquivo JSON encontrado na pasta especificada do Google Drive."
          break
        else
          # Dentro do loop onde processa os arquivos JSON
          response.files.each do |file|
            file_name = file.name
            file_id = file.id

            # Verifica se o arquivo já foi processado
            if ProcessedFile.exists?(file_id: file_id)
              log_file.puts "Processando arquivo JSON: #{file_name} (ID: #{file_id})"
              log_file.flush
              next
            end

            puts "Baixando e processando arquivo JSON: #{file_name} (ID: #{file_id})"

            begin
              # Baixar o arquivo JSON
              file_content = StringIO.new
              drive_service.get_file(file_id, download_dest: file_content)

              # Converter o conteúdo do JSON para string UTF-8, substituindo caracteres inválidos
              file_content.rewind
              json_content = file_content.read.force_encoding('UTF-8').encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

              # Limpar e processar o conteúdo JSON
              cleaned_content = clean_json_content(json_content)
              json_data = JSON.parse(cleaned_content)

              # Extraindo os dados do nome do arquivo
              date_string = file_name.split("_")[0]  # Extrai '240323' do nome do arquivo
              time_string = file_name.split("_")[1]  # Extrai '160953' do nome do arquivo
              session_date = Date.strptime(date_string, '%y%m%d')
              session_time = Time.strptime(time_string, '%H%M%S')

              # Extrair as informações necessárias
              server_name = json_data["serverName"]
              session_type = json_data["sessionType"]
              track_name = json_data["trackName"]

              log_file.puts "Sessão: Data=#{session_date}, Hora=#{session_time}, Tipo=#{session_type}, Pista=#{track_name}"
              log_file.flush

              # Verifica se o serverName contém as palavras "Challenge" ou "Championship"
              if server_name.match?(/Challenge|Championship/i)
                log_file.puts "Processando como Championship: #{server_name}"
                log_file.flush

                # Extrair temporada e ano
                season_and_year = extract_season_and_year_from_server_name(server_name)
                season = season_and_year[:season]
                year = season_and_year[:year]

                # Verifica se os dados de resultados da sessão estão presentes
                if json_data["sessionResult"] && json_data["sessionResult"]["leaderBoardLines"]
                  leaderboard = json_data["sessionResult"]["leaderBoardLines"]
                  leaderboard.each do |entry|
                    car = entry["car"]
                    driver = car["drivers"].first

                    car_id = car["carId"]
                    race_number = car["raceNumber"]
                    car_model_id = car["carModel"].to_i  # Mantém o valor como integer
                    driver_first_name = driver["firstName"]
                    driver_last_name = driver["lastName"]
                    best_lap = entry["timing"]["bestLap"]
                    total_time = entry["timing"]["totalTime"]
                    lap_count = entry["timing"]["lapCount"]
                    cup_category = car["cupCategory"]

                    # Buscar o modelo do carro no banco de dados (car_model é integer agora)
                    car_model = CarModel.find_by(car_model: car_model_id)

                    if car_model.nil?
                      log_file.puts "CarModel com ID #{car_model_id} não encontrado, pulando."
                      log_file.flush
                      next
                    end

                    # Extrair as voltas
                    laps = json_data["laps"].select { |lap| lap["carId"] == car_id }

                    penalty_reason = json_data["penalties"]&.select { |p| p["carId"] == car_id }.map { |p| p["reason"] }
                    penalty_type = json_data["penalties"]&.select { |p| p["carId"] == car_id }.map { |p| p["penalty"] }
                    penalty_value = json_data["penalties"]&.select { |p| p["carId"] == car_id }.map { |p| p["penaltyValue"] }
                    penalty_violation_in_lap = json_data["penalties"]&.select { |p| p["carId"] == car_id }.map { |p| p["violationInLap"] }
                    penalty_cleared_in_lap = json_data["penalties"]&.select { |p| p["carId"] == car_id }.map { |p| p["clearedInLap"] }

                    # Extrair penalidades pós-corrida
                    post_race_penalty = json_data["post_race_penalties"]&.find { |p| p["carId"] == car_id }
                    post_race_penalty_reason = post_race_penalty ? post_race_penalty["reason"] : nil
                    post_race_penalty_type = post_race_penalty ? post_race_penalty["penalty"] : nil
                    post_race_penalty_value = post_race_penalty ? post_race_penalty["penaltyValue"] : nil
                    post_race_penalty_violation_in_lap = post_race_penalty ? post_race_penalty["violationInLap"] : nil
                    post_race_penalty_cleared_in_lap = post_race_penalty ? post_race_penalty["clearedInLap"] : nil

                    # Log dos pilotos sendo processados
                    log_file.puts "Processando piloto: #{driver_first_name} #{driver_last_name}, CarID: #{car_id}, RaceNumber: #{race_number}, CarModelID: #{car_model_id}"
                    log_file.flush  # Força a escrita imediata no arquiv

                    # Criar ou atualizar os dados no BD Championship, adicionando season e year
                    Championship.create!(
                      car_id: car_id,
                      race_number: race_number,
                      car_model: car_model,
                      driver_first_name: driver_first_name,
                      driver_last_name: driver_last_name,
                      best_lap: best_lap,
                      total_time: total_time,
                      lap_count: lap_count,
                      session_date: session_date,
                      session_time: session_time,
                      session_type: session_type,
                      track_name: track_name,
                      cup_category: cup_category,
                      laps: laps,
                      season: season,   # Adiciona a temporada identificada
                      year: year,       # Adiciona o ano identificado
                      penalty_reason: penalty_reason,
                      penalty_type: penalty_type,
                      penalty_value: penalty_value,
                      penalty_violation_in_lap: penalty_violation_in_lap,
                      penalty_cleared_in_lap: penalty_cleared_in_lap,
                      post_race_penalty_reason: post_race_penalty_reason,
                      post_race_penalty_type: post_race_penalty_type,
                      post_race_penalty_value: post_race_penalty_value,
                      post_race_penalty_violation_in_lap: post_race_penalty_violation_in_lap,
                      post_race_penalty_cleared_in_lap: post_race_penalty_cleared_in_lap
                    )
                  end

                  # Após processar o arquivo, salvar no banco de dados para evitar duplicação futura
                  ProcessedFile.create!(file_id: file_id)
                  log_file.puts "Arquivo #{file_name} processado e armazenado com sucesso no Championship."
                  log_file.flush
                else
                  log_file.puts "O arquivo #{file_name} não contém os dados esperados para Championship, ignorando."
                  log_file.flush
                end

              else
                log_file.puts "Processando como Driver: #{server_name}"
                log_file.flush

                # Verifica se os dados de resultados da sessão estão presentes
                if json_data["sessionResult"] && json_data["sessionResult"]["leaderBoardLines"]
                  leaderboard = json_data["sessionResult"]["leaderBoardLines"]
                  leaderboard.each do |entry|
                    car = entry["car"]
                    driver = car["drivers"].first

                    car_id = car["carId"]
                    race_number = car["raceNumber"]
                    car_model_id = car["carModel"].to_i  # Mantém o valor como integer
                    driver_first_name = driver["firstName"]
                    driver_last_name = driver["lastName"]
                    best_lap = entry["timing"]["bestLap"]
                    total_time = entry["timing"]["totalTime"]
                    lap_count = entry["timing"]["lapCount"]

                    # Buscar o modelo do carro no banco de dados (car_model é integer agora)
                    car_model = CarModel.find_by(car_model: car_model_id)

                    if car_model.nil?
                      log_file.puts "CarModel com ID #{car_model_id} não encontrado, pulando."
                      log_file.flush
                      next
                    end

                    # Extrair as voltas
                    laps = json_data["laps"].select { |lap| lap["carId"] == car_id }

                    # Extrair penalidades durante a corrida
                    penalty = json_data["penalties"]&.find { |p| p["carId"] == car_id }
                    penalty_reason = penalty ? penalty["reason"] : nil
                    penalty_type = penalty ? penalty["penalty"] : nil
                    penalty_value = penalty ? penalty["penaltyValue"] : nil
                    penalty_violation_in_lap = penalty ? penalty["violationInLap"] : nil
                    penalty_cleared_in_lap = penalty ? penalty["clearedInLap"] : nil

                    # Extrair penalidades pós-corrida
                    post_race_penalty = json_data["post_race_penalties"]&.find { |p| p["carId"] == car_id }
                    post_race_penalty_reason = post_race_penalty ? post_race_penalty["reason"] : nil
                    post_race_penalty_type = post_race_penalty ? post_race_penalty["penalty"] : nil
                    post_race_penalty_value = post_race_penalty ? post_race_penalty["penaltyValue"] : nil
                    post_race_penalty_violation_in_lap = post_race_penalty ? post_race_penalty["violationInLap"] : nil
                    post_race_penalty_cleared_in_lap = post_race_penalty ? post_race_penalty["clearedInLap"] : nil

                    # Log dos pilotos sendo processados
                    log_file.puts "Processando piloto: #{driver_first_name} #{driver_last_name}, CarID: #{car_id}, RaceNumber: #{race_number}, CarModelID: #{car_model_id}"
                    log_file.flush  # Força a escrita imediata no arquiv

                    # Criar ou atualizar o piloto com os dados
                    Driver.create!(
                      car_id: car_id,
                      race_number: race_number,
                      car_model: car_model,
                      driver_first_name: driver_first_name,
                      driver_last_name: driver_last_name,
                      best_lap: best_lap,
                      total_time: total_time,
                      lap_count: lap_count,
                      session_date: session_date,
                      session_time: session_time,
                      session_type: session_type,
                      track_name: track_name,
                      laps: laps,

                      penalty_reason: penalty_reason,
                      penalty_type: penalty_type,
                      penalty_value: penalty_value,
                      penalty_violation_in_lap: penalty_violation_in_lap,
                      penalty_cleared_in_lap: penalty_cleared_in_lap,

                      post_race_penalty_reason: post_race_penalty_reason,
                      post_race_penalty_type: post_race_penalty_type,
                      post_race_penalty_value: post_race_penalty_value,
                      post_race_penalty_violation_in_lap: post_race_penalty_violation_in_lap,
                      post_race_penalty_cleared_in_lap: post_race_penalty_cleared_in_lap
                    )
                  end

                  # Após processar o arquivo, salvar no banco de dados para evitar duplicação futura
                  ProcessedFile.create!(file_id: file_id)
                  log_file.puts "Arquivo #{file_name} processado e armazenado com sucesso no Driver."
                  log_file.flush
                else
                  log_file.puts "O arquivo #{file_name} não contém os dados esperados, ignorando."
                  log_file.flush
                end
              end

              # Incrementar o contador de arquivos processados
              processed_count += 1
              break if max_files && processed_count >= max_files

            rescue => e
              log_file.puts "Erro ao processar o arquivo #{file_name}: #{e.message}"
              log_file.flush
            end
          end
        end

        page_token = response.next_page_token
        break if page_token.nil? || (max_files && processed_count >= max_files)
      end
    rescue => e
      log_file.puts "Erro durante o processo de download e processamento: #{e.message}"
      log_file.flush
    end

    log_file.close
  end

  def clean_json_content(content)
    # Remover caracteres não imprimíveis
    cleaned_content = content.gsub(/[^[:print:]\n\t]/, '').strip

    # Remover vírgulas extras antes de fechar colchetes e chaves
    cleaned_content = cleaned_content.gsub(/,\s*\}/, '}')
    cleaned_content = cleaned_content.gsub(/,\s*\]/, ']')

    # Tentar corrigir chaves ou colchetes malformados
    cleaned_content = cleaned_content.gsub(/\{[\s,]*\}/, '{}') # Corrige objetos vazios malformados
    cleaned_content = cleaned_content.gsub(/\[[\s,]*\]/, '[]') # Corrige arrays vazios malformados

    cleaned_content
  end

  def index
    @sponsors = Sponsor.all
  end

  def pilotos
    @pilots = Pilot.all
  end

  def patrocinio
    @sponsors = Sponsor.all
  end

  def oauth2callback
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = "default"

    code = params[:code]

    if code.nil?
      flash[:error] = "Código de autorização não encontrado"
      redirect_to root_path
    else
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id,
        code: code,
        base_url: OOB_URI
      )

      if credentials
        flash[:notice] = "Autorização bem-sucedida!"
        redirect_to root_path
      else
        flash[:error] = "Erro ao armazenar as credenciais"
        redirect_to root_path
      end
    end
  end
end
