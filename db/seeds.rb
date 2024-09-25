# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create(full_name: 'Diego Leal', email: 'leal.goedi@gmail.com', password: '123456')

car_data = {
  "0" => "Porsche 991 GT3 R 2018",
  "1" => "Mercedes-AMG GT3 2015",
  "2" => "Ferrari 488 GT3 2018",
  "3" => "Audi R8 LMS 2015",
  "4" => "Lamborghini Huracán GT3 2015",
  "5" => "McLaren 650S GT3 2015",
  "6" => "Nissan GT-R Nismo GT3 2018",
  "7" => "BMW M6 GT3 2017",
  "8" => "Bentley Continental GT3 2018",
  "9" => "Porsche 991 II GT3 Cup 2017",
  "10" => "Nissan GT-R Nismo GT3 2015",
  "11" => "Bentley Continental GT3 2015",
  "12" => "AMR V12 Vantage GT3 2013",
  "13" => "Reiter Engineering R-EX GT3 2017",
  "14" => "Emil Frey Jaguar G3 2012",
  "15" => "Lexus RC F GT3 2016",
  "16" => "Lamborghini Huracan GT3 Evo 2019",
  "17" => "Honda NSX GT3 2017",
  "18" => "Lamborghini Huracan SuperTrofeo 2015",
  "19" => "Audi R8 LMS Evo 2019",
  "20" => "AMR V8 Vantage 2019",
  "21" => "Honda NSX GT3 Evo 2019",
  "22" => "McLaren 720S GT3 2019",
  "23" => "Porsche 991 II GT3 R 2019",
  "24" => "Ferrari 488 GT3 Evo 2020",
  "25" => "Mercedes-AMG GT3 2020",
  "26" => "Ferrari 488 Challenge Evo 2020",
  "27" => "BMW M2 Club Sport Racing 2020",
  "28" => "Porsche 992 GT3 Cup 2021",
  "29" => "Lamborghini Huracán SuperTrofeo EVO2 2021",
  "30" => "BMW M4 GT3 2022",
  "31" => "Audi R8 LMS GT3 Evo 2 2022",
  "32" => "Ferrari 296 GT3 2023",
  "33" => "Lamborghini Huracan GT3 Evo 2 2023",
  "34" => "Porsche 992 GT3 R 2023",
  "35" => "McLaren 720S GT3 Evo 2023",
  "36" => "Ford Mustang GT3",
  "50" => "Alpine A110 GT4 2018",
  "51" => "Aston Martin Vantage GT4 2018",
  "52" => "Audi R8 LMS GT4 2018",
  "53" => "BMW M4 GT4 2018",
  "55" => "Chevrolet Camaro GT4 2017",
  "56" => "Ginetta G55 GT4 2012",
  "57" => "KTM X-Bow GT4 2016",
  "58" => "Maserati MC GT4 2016",
  "59" => "McLaren 570S GT4 2016",
  "60" => "Mercedes AMG GT4 2016",
  "61" => "Porsche 718 Cayman GT4 Clubsport 2019",
  "80" => "Audi R8 LMS GT2 2021",
  "82" => "KTM XBOW GT2 2021",
  "83" => "Maserati MC20 GT2 2023",
  "84" => "Mercedes AMG GT2 2023",
  "85" => "Porsche 911 GT2 RS CS Evo 2023",
  "86" => "Porsche 935 2019"
}

car_data.each do |car_id, car_name|
  # Aqui você está usando o car_id (como "0", "1", etc.) e o car_name para criar os registros
  CarModel.create(car_id: car_id, car_name: car_name) # Ajuste a categoria conforme necessário
end
