#require 'faraday'
require "utility"
require "rails"

module Utility
  class Engine < ::Rails::Engine
    isolate_namespace Utility
  
  end
end