class ApplicationController < ActionController::Base
  include Spree::Core::ControllerHelpers::Order #adds a before filter for set_current_order
  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Common
  include Spree::Core::ControllerHelpers::Store

  helper_method :user_class, :check_apartment_opening

#   before_filter :set_current_order
#   before_filter :associate_user
  before_filter :check_cache
  before_filter :store_utm
  before_filter :log_session
  before_filter :log_visit
  before_filter :log_user_class
  before_filter :set_per_page_preference
  before_filter :set_fonts_loaded
  #before_filter :debug_spree_preferences


  protect_from_forgery
  layout proc{ |c| c.request.xhr? ? "lightbox" : "application" }


#   These don't work with Rails 3.2+
#   rescue_from Exception, with: :render_404
#   rescue_from ActionController::RoutingError, with: :render_404
#   rescue_from ActionController::UnknownController, with: :render_404
#   rescue_from ActionController::UnknownAction, with: :render_404
#   rescue_from ActiveRecord::RecordNotFound, with: :render_404


#    def default_url_options
#       {host: ClearCMS.config.default_host }
#    end


  def current_site
    ClearCMS::Site.first
  end

  def products
    Product.where(:site_id=>current_site.id)
  end

private

  def render_404(exception = nil)
    respond_to do |type|
      type.html { render :status => :not_found, :template => "static/status_404", :formats => [:html] }#, :layout => nil}
      type.all  { render :status => :not_found, :nothing => true }
    end
  end

  def check_cache
    if params[:clear_cache]
      results=Rails.cache.clear
      logger.info "CACHE CLEARED: #{results}"
    end
  end

  def store_utm
    session[:utm_medium] = params[:utm_medium] if params[:utm_medium]
    session[:utm_source] = params[:utm_source] if params[:utm_source]
  end

  def log_session
    logger.debug "Session: #{session.to_hash}"
  end

  #TBD: should be called once per session creation / "new" visit
  def log_visit
    if !session[:logged_visit] && session[:logged_visit]=true
      behavior = behavior_cookie

      if !defined?(behavior["visits"]) || !(behavior["visits"].is_a? Integer)
        behavior["visits"] = 1
      else
        behavior["visits"] += 1
      end

      cookies.permanent[:behavior] = behavior.to_json
    end
  end


  def user_class
    return nil unless current_spree_user
    return @current_user_class if @current_user_class # memoize it per request.

    current_user_roles = current_spree_user.spree_roles.map(&:name)

    if current_user_roles.include?('retail')
      @current_user_class = 'staff_retail'
    elsif current_user_roles.include?('customer_service')
      @current_user_class = 'staff_customer_service'
    elsif current_user_roles.include?('staff')
      @current_user_class = 'staff'
    else
      @current_user_class = 'registered'
    end
  end


  #TBD: should only be called after successful login (perhaps when spree_current_user goes from false to true)
  def log_user_class
    if current_spree_user && !session[:logged_user_class] && session[:logged_user_class]=true
      behavior = behavior_cookie
      behavior["user_class"] = user_class
      cookies.permanent[:behavior] = behavior.to_json
    end
  end

  def behavior_cookie
    begin
      cookies[:behavior] ? JSON.parse(cookies[:behavior]) : {}
    rescue => e
      Airbrake.notify(e, :error_message=>"Couldn't parse behavior cookie: #{cookies[:behavior]}")
      logger.debug cookies.inspect
      {}
    end
  end

  def set_fonts_loaded
    begin
      behavior = behavior_cookie
      # TDOO: do we need this as a session value, or just a method that can be called in the view
      session[:fonts_loaded] = behavior_cookie["features"] && behavior_cookie["features"]["webfonts"] == true
    rescue => e
      Airbrake.notify(e, :error_message=>"Error with session[:fonts_loaded]")
    end
  end

  def debug_spree_preferences
    logger.debug Spree::Config.preferences
  end

  def per_page_preference
    session[:per_page]||params[:per_page]
  end

  def set_per_page_preference
    case params.delete(:per_page_preference)
      when 'less'
        session[:per_page]=Settings.pagination.per_page_less
      when 'more'
        session[:per_page]=Settings.pagination.per_page_more
    end
  end

  def check_apartment_opening(apartment)
    return nil if !apartment.open_close_times.present?
    time_info = apartment.open_close_times
    days = time_info.gsub("\r\n", '').split(',')
    today = Date.today
    status = "Closed Today"
    target = days.select { |day| Date.today.send("#{day.split(':').first}?") }.first
    times = target.split('-')
    if times.last == 'closed'
      return status
    else
      current_hour = Time.now.hour
      if current_hour < times.first.to_i
        open = times.first.to_i
        open = times.first.to_i - 12 if times.first.to_i > 12
        open_lang = open == times.first.to_i ? 'a.m.' : 'p.m.'
        close = times.last.to_i
        close = times.last.to_i - 12 if times.last.to_i > 12
        status = "Open from #{open} #{open_lang} to #{close} p.m."
      elsif current_hour < times.last.to_i
        close = times.last.to_i
        close = times.last.to_i - 12 if times.last.to_i > 12
        status = "Open today until #{close} p.m."
      else
        status = "Currently Closed"
      end
      return status
    end
  end

end


