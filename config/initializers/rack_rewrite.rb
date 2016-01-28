# moved to production.rb
# Rails.application.config.middleware.insert_before('Rack::Lock', 'Rack::Rewrite') do
#   r301 /.*/,  Proc.new {|path, rack_env| "http://www.#{rack_env['SERVER_NAME']}#{path}" },     :if => Proc.new {|rack_env| !!(rack_env['SERVER_NAME'] =~ /^theline\.com$/i)}
# 
# #   r301 '/pages/about-us', '/about-us'
# #   r301 '/pages/forms/contact-us', '/contact'
# #   r301 '/hello', '/welcome/hi'
# end

