class Track < ApplicationRecord
  has_many :drivers
  has_many :championships
end
