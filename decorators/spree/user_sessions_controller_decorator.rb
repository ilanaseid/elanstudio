Spree::UserSessionsController.class_eval {
  layout proc{ |c| c.request.xhr? ? "lightbox" : "application" }

  #overriding the spree user sessions create method because it doesn't properly handle paranoid=false to return whether email exists or not
  def create
    super
  end
}
