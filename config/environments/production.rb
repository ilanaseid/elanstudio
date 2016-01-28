Theline::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true
  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  #config.serve_static_assets = false
  config.serve_static_files = true
  config.static_cache_control = "public, max-age=2592000"


  # Compress JavaScripts and CSS
  #config.assets.compress = true
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = :sass

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx
  config.action_dispatch.x_sendfile_header = nil

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  #config.force_ssl = true
  config.middleware.use Rack::SslEnforcer, :except => [%r{/brightpearl/webhooks.*}], :strict => true


  # See everything in the log (default is :info)
  config.log_level = :debug

  config.log_tags = [-> request {request.env['HTTP_X_REQUEST_ID']}, :ip]

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Use a different cache store in production
  redis_url = ENV['REDIS_URL']

  # Redis cache using redis-store
  config.cache_store = :redis_store, redis_url #, {expires_in: 24.hours}


#   config.cache_store = :redis_store, redis_url #, { expires_in: 90.minutes }
#   #config.cache_store = :dalli_store
#
#   config.action_dispatch.rack_cache = {
#     :metastore    => "#{ENV['REDIS_URL']}/metastore",
#     #:entitystore  => 'file:tmp/cache/rack/body',
#     :entitystore  => "#{ENV['REDIS_URL']}/entitystore",
#     #:allow_reload => false
#   }
#
#   config.middleware.insert_before Rack::Cache, 'ClearCMS::Rack::StaticCache', urls: ["#{config.assets.prefix}/", "cmn/"], root: 'public', cache_control: 'public'



  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  config.action_controller.asset_host = 'https://dvic4s0y3qk6b.cloudfront.net'

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  config.assets.precompile += %w( application_head.js superuser.js superuser.css icons.data.png.css icons.data.svg.css icons.fallback.css )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  #config.threadsafe! unless $rails_rake_task

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  if ENV['HTTP_AUTH']
    config.middleware.insert_before("Warden::Manager","::Rack::Auth::Basic", "The Line: Protected") do |u, p|
      (u == ENV['HTTP_AUTH'].split(':')[0] && p == ENV['HTTP_AUTH'].split(':')[1])
    end
  end


  config.middleware.insert_after('ActionDispatch::Static', 'Rack::Rewrite') do
    r301 /.*/,  Proc.new {|path, rack_env| "https://www.#{rack_env['SERVER_NAME']}#{path}" }, :if => Proc.new {|rack_env| !!(rack_env['SERVER_NAME'] =~ /^theline\.com$/i)}
    #   r301 '/pages/about-us', '/about-us'
    #   r301 '/pages/forms/contact-us', '/contact'
    #   r301 '/hello', '/welcome/hi'
  end

#   if ENV['HTTP_AUTH']
#     config.middleware.insert_before(0,"::Rack::Auth::Basic", "The Line: Protected") do |u, p|
#       (u == ENV['HTTP_AUTH'].split(':')[0] && p == ENV['HTTP_AUTH'].split(':')[1])
#     end
#   end

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
