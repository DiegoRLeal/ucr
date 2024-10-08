Rails.application.config.middleware.use OmniAuth::Builder do
  puts "Steam API Key: #{ENV['STEAM_WEB_API_KEY']}"  # Adicione esta linha para verificar a chave
  provider :steam, ENV['STEAM_WEB_API_KEY']
end
