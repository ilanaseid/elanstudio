Spree::StoreController.class_eval do 
  
  def unauthorized
    if try_spree_current_user
      flash[:error] = Spree.t(:authorization_failure)
      redirect_to '/'
    else
      store_location
      url = spree.respond_to?(:login_path) ? spree.login_path : spree.root_path
      redirect_to url
    end
  end


  private   
 
end