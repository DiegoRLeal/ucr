class MainsController < ApplicationController
  def index
    @name = User.first.email
  end

  def new

  end

  def sobre_nos
  end

  def pilotos
  end

  def campeonatos
  end

  def fale_conosco
  end
end
