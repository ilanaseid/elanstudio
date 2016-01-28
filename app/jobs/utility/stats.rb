require 'pp'

module Utility

  class Stats
    include Sidekiq::Worker
  
    def perform
      GC.start 
      pp GC.stat 
    end
  
  end
end