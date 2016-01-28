require 'active_support'
#require 'utility/railtie'
require 'utility/engine'

module Utility
  extend ActiveSupport::Autoload

  autoload :Brightpearl
  autoload :Content
end