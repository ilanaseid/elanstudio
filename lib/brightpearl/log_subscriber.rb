module Brightpearl
  class LogSubscriber < ActiveSupport::LogSubscriber
    def request(event)
      result = event.payload[:result]
      info "#{event.payload[:method].to_s.upcase} #{event.payload[:request_uri]}"
      info "--> %d %s %d (%.1fms)" % [result.code, result.message, result.body.to_s.length, event.duration]
    end

    def logger
      Brightpearl::Base.logger
    end
  end
end

Brightpearl::LogSubscriber.attach_to :brightpearl