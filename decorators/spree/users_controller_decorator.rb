Spree::UsersController.class_eval do
  layout proc{ |c| c.request.xhr? ? false : "application" }


  def update
    if @user.update_with_password(user_params)
      flash.now[:notice] = Spree.t(:account_updated)
      sign_in(@user, :event => :authentication, :bypass => true) # this logic needed b/c devise wants to log us out after password changes
      respond_to_account_update(:success)
    else
      flash[:error] = @user.errors.full_messages.join('<br> ').html_safe
      respond_to_account_update(:failure)
    end
  end

  def show
    # decorator needed in order to add email subscriber info
    @user = current_spree_user
    @email_preference = EmailPreference.new(@user.email)
    respond_with(@user)
  end

  private

  def user_params
    params.require(:user).permit(:firstname, :lastname, :email, :password, :password_confirmation, :current_password, :disable_staff_inventory_ui)
  end

  def respond_to_account_update(status)
    if request.xhr?          # any partial, success or failure
      render :partial => appropriate_account_partial(status)
    elsif status == :success # full page success, back to account page with new info
      redirect_to(spree.account_url, notice: Spree.t(:account_updated))
    else                     # full page failure, back to full page of that form, with errors
      redirect_to(spree.edit_account_path({change_password: params[:user][:password].present?}))
    end
  end

  def appropriate_account_partial(status)
    if status == :success # show them the new info
      params[:user][:password].present? ? 'spree/users/password_info' : 'spree/users/contact_info'
    else                  # give them the form again.
      params[:user][:password].present? ? 'spree/users/password_form' : 'spree/shared/user_form_account_page'
    end
  end

end
