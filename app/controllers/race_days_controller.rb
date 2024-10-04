class RaceDaysController < ApplicationController
  before_action :set_race_day, only: [:show]

  def index
    @race_days = RaceDay.all
  end

  def show
    @race_day = RaceDay.find(params[:id])
  end

  def new
    @race_day = RaceDay.new
  end

  def create
    @race_day = RaceDay.new(race_day_params)

    if @race_day.save
      redirect_to @race_day, notice: 'Dia de corrida criado com sucesso.'
    else
      render :new
    end
  end

  private

  def set_race_day
    @race_day = RaceDay.find(params[:id])
  end

  def race_day_params
    params.require(:race_day).permit(:date, :track, :max_pilots)
  end
end
