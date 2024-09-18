class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    sidebar_path # Substitua por seu caminho de rota para sidebar.html.erb
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
  end
end
