class StaticController < ApplicationController

  def timeout 
    sleep 45
  end
  
  def usersnap
    cookies[:usersnap]=true if params[:enable]
    cookies.delete(:usersnap) if params[:disable]
  end
  
  def status_404
    render :status=>404
  end
  
  def status_500
    #render :status=>500
    
    render :file => 'public/500.html', :status => 500, :layout => false
  end
  
end
