# activesupport_path = File.expand_path('../../../activesupport/lib', __FILE__)
# $:.unshift(activesupport_path) if File.directory?(activesupport_path) && !$:.include?(activesupport_path)
# 
# activemodel_path = File.expand_path('../../../activemodel/lib', __FILE__)
# $:.unshift(activemodel_path) if File.directory?(activemodel_path) && !$:.include?(activemodel_path)

require 'active_support'
require 'active_model'
require 'brightpearl/engine'
#require 'brightpearl/configuration'

module Brightpearl
  extend ActiveSupport::Autoload

  autoload :Base
  autoload :Connection
  autoload :CustomMethods
  autoload :Formats
  autoload :HttpMock
  autoload :Observing
  autoload :Schema
  autoload :Validations

  autoload :ProductService
  autoload :OrderService
  autoload :ContactService
  autoload :WarehouseService
  autoload :IntegrationService

#   class << self
#     attr_accessor :config
# 
#     def config
#       self.config = Configuration.new unless @config
#       @config
#     end
#   end
# 
#   def self.configure
#     self.config ||= Configuration.new
# 
#     yield(self.config)
# 
#     after_configure
#   end
# 
#   def self.after_configure
# 
#   end

end
