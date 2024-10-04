class PilotRegistrationsController < ApplicationController
  before_action :set_race_day, only: [:new, :create]

  def new
    @pilot_registration = PilotRegistration.new
    used_car_numbers = @race_day.pilot_registrations.pluck(:car_number_id)
    @available_car_numbers = @race_day.car_numbers.where.not(id: used_car_numbers)
  end

  def create
    @pilot_registration = @race_day.pilot_registrations.new(pilot_registration_params)

    if @race_day.pilot_registrations.count >= @race_day.max_pilots
      # Mostrar a mensagem de alerta, mas permitir que o piloto seja salvo
      flash[:alert] = "As inscrições estão completas. Você foi adicionado à lista de espera."
    else
      flash[:notice] = "Inscrição realizada com sucesso."
    end

    if @pilot_registration.save
      redirect_to race_day_path(@race_day)
    else
      used_car_numbers = @race_day.pilot_registrations.pluck(:car_number_id)
      @available_car_numbers = @race_day.car_numbers.where.not(id: used_car_numbers)
      render :new
    end
  end

  private

  def set_race_day
    @race_day = RaceDay.find(params[:race_day_id])
  end

  def pilot_registration_params
    params.require(:pilot_registration).permit(:pilot_name, :car_number_id)
  end
end
