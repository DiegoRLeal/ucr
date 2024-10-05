namespace :db do
  desc "Corrigir o campo session_time para remover a data"
  task fix_session_time: :environment do
    Driver.find_each do |driver|
      if driver.session_time.present?
        # Extrair apenas a parte da hora de session_time
        new_session_time = driver.session_time.strftime('%H:%M:%S')
        driver.update(session_time: Time.parse(new_session_time))  # Salvar como hora
        puts "Corrigido session_time para o registro ID #{driver.id}: #{new_session_time}"
      end
    end

    Championship.find_each do |championship|
      if championship.session_time.present?
        # Extrair apenas a parte da hora de session_time
        new_session_time = championship.session_time.strftime('%H:%M:%S')
        championship.update(session_time: Time.parse(new_session_time))  # Salvar como hora
        puts "Corrigido session_time para o registro ID #{championship.id}: #{new_session_time}"
      end
    end

    puts "Correção concluída!"
  end
end
