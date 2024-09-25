module CarsHelper
  def car_image_path(car_model)
    puts "Car model received: #{car_model}"  # Verifica o valor recebido

    car_images = {
      "0" => "porsche.png",
      "1" => "mercedes.png",
      "2" => "ferrari.png",
      "3" => "audi",
      "4" => "lamborghini.png",
      "5" => "mclaren.png",
      "6" => "nissan.png",
      "7" => "bmw.png",
      "8" => "bentley.png",
      "9" => "porsche.png",
      "10" => "nissan.png",
      "11" => "bentley.png",
      "12" => "amr.png",
      # "13" => "reiter.png",
      # "14" => "emil.png",
      # "15" => "lexus.png",
      "16" => "lamborghini.png",
      "17" => "honda.png",
      "18" => "lamborghini.png",
      "19" => "audi.png",
      "20" => "amr.png",
      "21" => "honda.png",
      "22" => "mclaren.png",
      "23" => "porsche.png",
      "24" => "ferrari.png",
      "25" => "mercedes.png",
      "26" => "ferrari.png",
      "27" => "bmw.png",
      "28" => "porsche.png",
      "29" => "lamborghini.png",
      "30" => "bmw.png",
      "31" => "audi.png",
      "32" => "ferrari_296.png",
      "33" => "lamborghini.png",
      "34" => "porsche.png",
      "35" => "mclaren.png",
      "36" => "ford.png",
      # "50" => "alpine.png",
      "51" => "amr.png",
      "52" => "audi.png",
      "53" => "bmw.png",
      # "55" => "chevrolet.png",
      # "56" => "ginetta.png",
      # "57" => "ktm.png",
      # "58" => "maserati.png",
      "59" => "mclaren.png",
      "60" => "mercedes.png",
      "61" => "porsche.png",
      "80" => "audi.png",
      # "82" => "ktm.png",
      # "83" => "maserati.png",
      "84" => "mercedes.png",
      "85" => "porsche.png",
      "86" => "porsche.png"
    }

    # Converte o car_model para string (caso ainda não seja)
    image_name = car_images[car_model.to_s]

    if image_name.present?
      puts "Image found: #{image_name}"  # Verifica se a imagem foi encontrada
      asset_path("cars/#{image_name}")
    else
      puts "Image not found, using default image"
      asset_path("cars/default_car_image.png")  # Fallback para uma imagem padrão
    end
  end
end
