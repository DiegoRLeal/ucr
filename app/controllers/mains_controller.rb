require 'roo'
require 'net/sftp'

class MainsController < ApplicationController
  def job
    # Definir credenciais de ambiente para o SFTP no Heroku
    sftp_host = ENV['SFTP_HOST']
    sftp_user = ENV['SFTP_USER']
    sftp_password = ENV['SFTP_PASSWORD']
    sftp_directory = "/path/to/excel/files"

    # Conectar ao servidor SFTP
    Net::SFTP.start(sftp_host, sftp_user, password: sftp_password) do |sftp|
      # Listar arquivos no diretório
      sftp.dir.foreach(sftp_directory) do |entry|
        next if entry.name == '.' || entry.name == '..'

        file_path = "#{sftp_directory}/#{entry.name}"

        # Baixar arquivo XLS
        sftp.download!(file_path, "/tmp/#{entry.name}")

        # Ler o arquivo XLS com a gem 'roo'
        xlsx = Roo::Excelx.new("/tmp/#{entry.name}")

        # Processar o arquivo e salvar no banco de dados
        xlsx.each_row_streaming(offset: 1) do |row|
          # Aqui você pode ajustar conforme o seu modelo no banco
          Customer.create(
            name: row[0].cell_value,
            email: row[1].cell_value
          )
        end

        puts "Arquivo #{entry.name} processado."
      end
    end
  end
end
