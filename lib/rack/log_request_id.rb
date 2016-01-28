module Rack
  class LogRequestID
    def initialize(app)
      @app = app
    end
  
    def call(env)
      #puts env.inspect
      puts "request_id=#{env['HTTP_HEROKU_REQUEST_ID']}"
      @app.call(env)
    end
  end  
end