require "google/apis/drive_v3"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"
require "json"

class MainsController < ApplicationController
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

    folder_id = '1NVadU7DI7-qqcAmQ1XOCB_1VellFH3-c'  # ID da pasta no Google Drive
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
            file_name = file.name  # Nome do arquivo (exemplo: '240323_160953_R.json')
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
              session_date = Date.strptime(date_string, '%d%m%y')  # Converte '240323' em data
              session_time = Time.strptime(time_string, '%H%M%S')  # Converte '160953' em hora

              session_type = json_data["sessionType"]  # Extrai o sessionType
              track_name = json_data["trackName"]      # Extrai o trackName

              puts "Sessão: Data=#{session_date}, Hora=#{session_time}, Tipo=#{session_type}, Pista=#{track_name}"

              # Agora, além de salvar os pilotos, você pode salvar essas informações no Driver ou outro model

              # Iterar sobre os pilotos e salvar os dados
              if json_data["sessionResult"] && json_data["sessionResult"]["leaderBoardLines"]
                leaderboard = json_data["sessionResult"]["leaderBoardLines"]
                leaderboard.each do |entry|
                  car = entry["car"]
                  driver = car["drivers"].first

                  car_id = car["carId"]
                  race_number = car["raceNumber"]
                  car_model = car["carModel"]
                  driver_first_name = driver["firstName"]
                  driver_last_name = driver["lastName"]
                  best_lap = entry["timing"]["bestLap"]
                  total_time = entry["timing"]["totalTime"]
                  lap_count = entry["timing"]["lapCount"]

                  puts "Dados extraídos: car_id=#{car_id}, race_number=#{race_number}, driver=#{driver_first_name} #{driver_last_name}"

                  # Crie o piloto com as novas informações de sessão
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
                    track_name: track_name
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
              break if max_files && processed_count >= max_files  # Parar após processar max_files arquivos (se definido)

            rescue => e
              puts "Erro ao processar o arquivo #{file_name}: #{e.message}"
            end
          end
        end

        page_token = response.next_page_token
        break if page_token.nil? || (max_files && processed_count >= max_files)  # Parar o loop após max_files arquivos
      end
    rescue => e
      puts "Erro durante o processo de download e processamento: #{e.message}"
    end

    render plain: "Processamento concluído."
  end

  def job_view
    job  # Chama o método para baixar todos os arquivos JSON
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

  def pilotos
    @pilots = Driver.all
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
