module CarsHelper
  def car_image_path(car_model)
    puts "Car model received: #{car_model}"  # Verifica o valor recebido

    car_images = {
      "0" => "porsche_991_gt3_r_2018.png",
      # "1" => "mercedes_amg_gt3_2015.png",
      # "2" => "ferrari_488_gt3_2018.png",
      "30" => "bmw_m4_gt3_2022.png"
      # "32" => "ferrari_296_gt3_2023.png",
      # "34" => "porsche_992_gt3_r_2023.png",
      # Continue adicionando mais carros...
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
