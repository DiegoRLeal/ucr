require "google/apis/drive_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require "json"

class MainsController < ApplicationController
  before_action :authenticate_user!, only: [:sidebar]

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

    # Se as credenciais não forem encontradas, redirecionar para a página de login do Google
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      redirect_to url, allow_other_host: true
    end

    # Retornar as credenciais para serem usadas no serviço do Google Drive
    credentials
  end

  def job
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
          response.files.each do |file|
            file_name = file.name
            file_id = file.id

            # Verifica se o arquivo já foi processado
            if ProcessedFile.exists?(file_id: file_id)
              puts "O arquivo #{file_name} já foi processado anteriormente, pulando."
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

              session_type = json_data["sessionType"]
              track_name = json_data["trackName"]

              puts "Sessão: Data=#{session_date}, Hora=#{session_time}, Tipo=#{session_type}, Pista=#{track_name}"

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
                    puts "CarModel com ID #{car_model_id} não encontrado, pulando."
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

                  # Criar ou atualizar o piloto com os dados e penalidades
                  Driver.create!(
                    car_id: car_id,
                    race_number: race_number,
                    car_model: car_model,  # Passar a instância de CarModel ao invés de apenas o ID
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
                puts "Arquivo #{file_name} processado e armazenado com sucesso."
              else
                puts "O arquivo #{file_name} não contém os dados esperados, ignorando."
              end

              # Incrementar o contador de arquivos processados
              processed_count += 1
              break if max_files && processed_count >= max_files

            rescue => e
              puts "Erro ao processar o arquivo #{file_name}: #{e.message}"
            end
          end
        end

        page_token = response.next_page_token
        break if page_token.nil? || (max_files && processed_count >= max_files)
      end
    rescue => e
      puts "Erro durante o processo de download e processamento: #{e.message}"
    end
  end


  # def job_view
  #   job  # Chama o método para baixar todos os arquivos JSON
  # end

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

  # Método de callback para lidar com o código de autorização retornado pelo Google
  def oauth2callback
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)

    user_id = "default"

    # Obter o código de autorização da URL de callback
    code = params[:code]

    if code.nil?
      # Se não houver código de autorização, exibir uma mensagem de erro
      flash[:error] = "Código de autorização não encontrado"
      redirect_to root_path
    else
      # Trocar o código de autorização por tokens de acesso e refresh
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id,
        code: code,
        base_url: OOB_URI
      )

      if credentials
        # Redireciona para a página principal ou qualquer outra rota após a autorização bem-sucedida
        flash[:notice] = "Autorização bem-sucedida!"
        redirect_to root_path
      else
        flash[:error] = "Erro ao armazenar as credenciais"
        redirect_to root_path
      end
    end
  end
end
