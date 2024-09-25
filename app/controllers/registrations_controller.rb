class RegistrationsController < Devise::RegistrationsController

  def create
    super do |resource|
      if resource.persisted? # Se o cadastro foi bem-sucedido
        flash[:welcome] = true
        sign_in(resource) # Autentica automaticamente o usuário
        redirect_to sidebar_path and return # Redireciona para a página sidebar e encerra a ação
      end
    end
  end

  def edit
    if request.xhr? # Se for uma requisição AJAX
      render 'devise/registrations/edit', layout: false # Renderiza o arquivo edit.html.erb sem layout
    else
      super # Caso contrário, segue o fluxo padrão do Devise
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if update_resource(resource, account_update_params)
      if request.xhr?
        render json: {
          message: 'Profile updated successfully!',
          html: render_to_string(template: 'devise/registrations/edit', locals: { resource: resource.reload }),
          updated_user: {
            full_name: resource.full_name,
            email: resource.email
          }
        }, status: :ok
      else
        set_flash_message :notice, :updated
        redirect_to after_update_path_for(resource)
      end
    else
      clean_up_passwords resource
      if request.xhr?
        render json: {
          errors: resource.errors.full_messages,
          html: render_to_string(template: 'devise/registrations/edit', locals: { resource: resource })
        }, status: :unprocessable_entity
      else
        respond_with resource
      end
    end
  end

  protected

  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      resource.update_without_password(params.except(:current_password))
    else
      resource.update_with_password(params)
    end
  end
end
