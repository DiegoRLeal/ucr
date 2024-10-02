class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  private

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      I18n.locale = extract_locale_from_accept_language_header || I18n.default_locale
    end
  end

  def extract_locale_from_accept_language_header
    browser_locale = request.env['HTTP_ACCEPT_LANGUAGE']&.scan(/^[a-z]{2}/)&.first
    if browser_locale
      # Ajuste para 'pt-BR' se o idioma do navegador for 'pt'
      browser_locale = 'pt-BR' if browser_locale == 'pt'
      I18n.available_locales.map(&:to_s).include?(browser_locale) ? browser_locale : nil
    end
  end

  def default_url_options
    { locale: I18n.locale }
  end

  # protected

  def after_sign_in_path_for(resource)
    sidebar_path # Substitua por seu caminho de rota para sidebar.html.erb
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:avatar])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:number])
    devise_parameter_sanitizer.permit(:account_update, keys: [:number])
  end
end
