class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def steam
    Rails.logger.debug "OmniAuth auth hash: #{request.env['omniauth.auth'].inspect}"

    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Steam') if is_navigational_format?
    else
      session['devise.steam_data'] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def failure
    Rails.logger.debug "OmniAuth authentication failure! Request env: #{request.env.inspect}"
    redirect_to root_path
  end
end
