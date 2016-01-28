#require 'faraday'
require "brightpearl"
require "rails"

module Brightpearl
  class Engine < ::Rails::Engine
    isolate_namespace Brightpearl
 
 
    config.brightpearl = ActiveSupport::OrderedOptions.new

    initializer "brightpearl.set_configs" do |app|
      app.config.brightpearl.each do |k,v|
        Brightpearl::Base.send "#{k}=", v
      end
    end

  
    def self.activate
	    Dir.glob(File.join(Rails.application.root, "app/**/*_decorator*.rb")) do |c|	      
	      Rails.configuration.cache_classes ? require(c) : load(c)
	    end
  	end
    
    config.to_prepare &method(:activate).to_proc

  end
end
