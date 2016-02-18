GC::Profiler.enable

require File.expand_path('../boot', __FILE__)

require 'rails/all'


ActiveSupport::Logger.class_eval do
  #monkey patching here so there aren't duplicate lines in console/server
  def self.broadcast(logger)
    Module.new do
    end
  end
end


Bundler.require(:default, Rails.env)


module Elanstudio
  class Application < Rails::Application
    
    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end



    #config.i18n.enforce_available_locales = true
    # or if one of your gem compete for pre-loading, use
    #I18n.config.enforce_available_locales = true


    # Added for ClearCMS to eager load models so that their attributes are all available on the base class
    config.before_initialize do |app|
        app.config.paths.add 'app/models', :eager_load => true
    end

    # Reload cached/serialized classes before every request (in development
    # mode) or on startup (in production mode)
    config.to_prepare do
      #Rails.logger.debug 'FIRST PREPARE'
      Dir[ File.expand_path(Rails.root.join("app/models/*.rb")) ].each do |file|
          require_dependency file
      end
    end



    # Added by SPREE for their decorators and overrides
    config.watchable_dirs['decorators']=[:rb]
    config.to_prepare do
      #Rails.logger.debug 'SECOND PREPARE'
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Moved most of the decorators out of ../app because of race condition in loading between different enginese (spree_auth_devise was loading after our class_evals)
      Dir.glob(File.join(File.dirname(__FILE__), "../decorators/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # Load the Reporting Module files so we can see what reports are available
    config.to_prepare do
      Dir[ File.expand_path(Rails.root.join("app/jobs/reporting/*.rb")) ].each do |file|
        Rails.configuration.cache_classes ? require(file) : load(file)
      end

    end

    config.to_prepare do
      file = File.join(File.dirname(__FILE__), "initializers/spree.rb") #putting this here to get those overrides in dev on every edit/reload
      Rails.configuration.cache_classes ? require(file) : load(file)
    end


    config.generators do |g|
      g.orm :active_record
      #g.test_framework :test_unit
    end

    config.exceptions_app = self.routes

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Heroku requires this to be false, means the app is not loaded when precompiling
    config.assets.initialize_on_precompile = false

    #config.middleware.insert_before(0, "Rack::LogRequestID")

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    #config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '3.0'

    config.assets.precompile += ['email_subscribers.css', 'email_subscribers.js', 'shipstation/all.css']

    config.middleware.use Rack::Deflater

    #config.middleware.insert_after(0,Rack::Timeout)

    #config.middleware.use PumaStatsLogger::Middleware, logger: Rails.logger

    #config.middleware.use Mongoid::QueryCache::Middleware

    # prepare for next version of rails in which errors are no longer supressed in after_commit or after_rollback
    config.active_record.raise_in_transactional_callbacks = true


    config.before_initialize do |app|
      ClearCMS.configure do |config|
        config.s3_upload_bucket='elanstudio'
        config.fog_directory='elanstudio-cms'
        config.fog_region='us-east-1'
        config.fog_attributes={'Cache-Control'=>'public, max-age=1209600'}
        config.asset_host='https://d3azan0dcmrv2z.cloudfront.net'
        config.aws_access_key=ENV['AWS_ACCESS_KEY'] || 'na'
        config.aws_secret_access_key=ENV['AWS_SECRET_ACCESS_KEY'] || 'na'
        config.default_host=ENV['DEFAULT_HOST'] || 'localhost'
        config.mailer_sender='ilana@elanstudio.com'
        config.sidekiq_redis_url=ENV['SIDEKIQ_REDIS_URL'] || 'redis://localhost:6379'
      end
    end

    config.action_mailer.default_url_options = { host: ENV['DEFAULT_HOST'] || 'localhost', protocol: 'https'}
    #config.action_controller.asset_host = ENV['DEFAULT_HOST'] ? "https://#{ENV['DEFAULT_HOST']}" : 'localhost' #can't use this because we aren't loading env in precompile on heroku and it then rewrites to localhost

    config.action_mailer.asset_host = ENV['DEFAULT_HOST'] ? "https://#{ENV['DEFAULT_HOST']}" : 'http://localhost:5000'

    config.action_mailer.smtp_settings = {
      :address        => 'smtp.sendgrid.net',
      :port           => '587',
      :authentication => :plain,
      :user_name      => ENV['SENDGRID_USERNAME'],
      :password       => ENV['SENDGRID_PASSWORD'],
      :domain         => 'heroku.com',
      :enable_starttls_auto => true
      }

  end
end
