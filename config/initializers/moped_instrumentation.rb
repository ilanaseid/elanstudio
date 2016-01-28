# module Moped
#   module Instrumentation
#  
#     def self.instrument(klass)
#       klass.class_eval do 
#         def logging(operations)
#           instrument_start = (logger = Moped.logger) && logger.debug? && Time.new
#           yield
#         ensure
#           if instrument_start
#             instrument_end   = 1000 * (Time.new.to_f - instrument_start.to_f)
#             MopedLogSubscriber.runtime += instrument_end
#             log_operations(logger, operations, instrument_end)
#           end
#         end
#       end
#     end
#  
# #     class Railtie < Rails::Railtie
# #       initializer "moped.instrumentation" do |app|
# #         Moped::Instrumentation.instrument Moped::Node
# #         Moped::Instrumentation::MopedLogSubscriber.attach_to :action_controller
# #       end
# #     end
#  
#     class MopedLogSubscriber < ActiveSupport::LogSubscriber
#       def self.runtime=(value)
#         Thread.current["moped_rails_runtime"] = value
#       end
#  
#       def self.runtime
#         Thread.current["moped_rails_runtime"] ||= 0
#       end
#  
#       def self.reset_runtime!
#         rt, self.runtime = runtime, 0
#         rt
#       end
#  
#       def start_processing(event)
#         MopedLogSubscriber.reset_runtime!
#       end
#  
#       def process_action(event)
#         runtime = ("Mongo: (%.4fms)" % MopedLogSubscriber.runtime)
#         info(runtime)
#       end
#  
#       def logger
#         ActionController::Base.logger
#       end
#     end   
#   end
# end
# 
# 
# Moped::Instrumentation.instrument Moped::Node
# Moped::Instrumentation::MopedLogSubscriber.attach_to :action_controller