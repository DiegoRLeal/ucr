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

    # Definir a pasta 'results' para armazenar os arquivos baixados
    results_dir = File.join('app', 'results')
    FileUtils.mkdir_p(results_dir) unless File.directory?(results_dir)

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
            puts "Baixando arquivo JSON: #{file_name} (ID: #{file_id})"

            file_path = File.join(results_dir, file_name)
            begin
              # Baixar o arquivo JSON e salvá-lo na pasta 'results'
              File.open(file_path, 'wb') do |f|
                drive_service.get_file(file_id, download_dest: f)
              end
              puts "Arquivo #{file_name} baixado com sucesso em #{file_path}."

            rescue => e
              puts "Erro ao baixar o arquivo #{file_name}: #{e.message}"
            end
          end
        end

        page_token = response.next_page_token
        break if page_token.nil?  # Continua enquanto houver mais páginas de arquivos
      end
    rescue => e
      puts "Erro durante o processo de download: #{e.message}"
    end
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


  def show_specific_json
    # Pega o caminho da pasta 'results'
    results_dir = File.join('app', 'results')

    # Pegar todos os arquivos JSON na pasta
    json_files = Dir.glob(File.join(results_dir, '*.json'))

    if json_files.empty?
      @error_message = "Nenhum arquivo JSON foi encontrado na pasta results."
      return
    end

    # Inicializar a variável para armazenar os dados processados
    @all_leaderboards = []

    json_files.each do |json_file|
      begin
        # Ler o conteúdo de cada arquivo JSON em modo binário e converter para UTF-8
        file_content = File.open(json_file, "rb").read
        file_content = file_content.encode("UTF-8", invalid: :replace, undef: :replace, replace: '').strip

        if file_content.empty?
          @error_message = "O arquivo JSON '#{File.basename(json_file)}' está vazio."
          next
        end

        # Limpar o conteúdo do JSON antes de fazer o parsing
        cleaned_content = clean_json_content(file_content)

        # Fazer o parsing do conteúdo JSON
        @json_data = JSON.parse(cleaned_content)

        # Exibir uma mensagem de erro se o JSON não contiver os dados esperados
        if @json_data["sessionResult"].nil? || @json_data["sessionResult"]["leaderBoardLines"].nil?
          @error_message = "O arquivo JSON '#{File.basename(json_file)}' não contém os dados esperados."
          next
        else
          @leaderboard = @json_data["sessionResult"]["leaderBoardLines"]
          @all_leaderboards << { file: File.basename(json_file), data: @leaderboard }
        end

      rescue JSON::ParserError => e
        @error_message = "Erro ao processar o arquivo JSON '#{File.basename(json_file)}': #{e.message}"
      rescue Encoding::InvalidByteSequenceError => e
        @error_message = "Erro de codificação ao ler o arquivo JSON '#{File.basename(json_file)}': #{e.message}"
      rescue => e
        @error_message = "Erro ao processar o arquivo JSON '#{File.basename(json_file)}': #{e.message}"
      end
    end
  end

end
