Spree::BaseController.class_eval {
  layout proc{ |c| c.request.xhr? ? "lightbox" : "application" }
  
}
