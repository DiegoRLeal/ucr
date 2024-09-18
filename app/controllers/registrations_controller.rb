class RegistrationsController < Devise::RegistrationsController
  layout 'welcome', only: [:welcome]

  def welcome
    welcome_path
  end

  def edit
    if request.xhr? # Se for uma requisição AJAX
      render 'devise/registrations/edit', layout: false # Renderiza o arquivo edit.html.erb sem layout
    else
      super # Caso contrário, segue o fluxo padrão do Devise
    end
  end
  protected

  def after_sign_up_path_for(resource)
    welcome_path
  end
end
