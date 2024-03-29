ENV['LOG_LEVEL']='debug'

Elanstudio::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  config.eager_load = false

  #config.reload_classes_only_on_change = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true

  # CHANGE TO TRUE FOR CACHE TESTING
  config.action_controller.perform_caching = false

  #email preview custom preview_path
  config.action_mailer.preview_path = "#{Rails.root}/spec/previews"

  #config.action_dispatch.show_exceptions = true

  # Redis cache using redis-store
  # UNCOMMENT FOR CACHE TESTING
  #config.cache_store = :redis_store #, redis_url #, {expires_in: 24.hours}
  #config.action_view.cache_template_loading = true

  # Don't care if the mailer can't send
  # config.after_initialize do |app|  #overriding whatever spree is doing, ANNOYING
  #   app.config.action_mailer.perform_deliveries = true
  # end
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :file
  config.action_mailer.file_settings = { :location => 'tmp/emails' }
  config.action_mailer.default :charset => "utf-8"


  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

end
