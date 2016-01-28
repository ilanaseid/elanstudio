#require_dependency 'spree/user_registrations_controller'

Spree::UserRegistrationsController.class_eval do
  layout proc{ |c| c.request.xhr? ? "lightbox" : "application" }

  # POST /resource/sign_up
  def create
    @user = build_resource(params[:spree_user].merge(:utm_source=>session[:utm_source],:utm_medium=>session[:utm_medium]).permit(:firstname, :lastname, :email, :password, :utm_source, :utm_medium, :newsletter))

    # make signups from orders show return to root path
    session['spree_user_return_to'] = '/' if session['registration_from_checkout']
    session.delete('registration_from_checkout')

    if resource.save
      set_flash_message(:notice, :signed_up)
      sign_in(:spree_user, @user)
      session[:spree_user_signup] = true
      associate_user
      sign_in_and_redirect(:spree_user, @user)
    else
      clean_up_passwords(resource)
      render :new
    end
  end

end
