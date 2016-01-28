module Sidekiq
  module Middleware
    module Server
      class TaggedLogger

        def call(worker, item, queue)
          tag = "#{worker.class.to_s} JID-#{item['jid']}"
          ::Rails.logger.tagged(tag) do
            job_info = "Start at #{Time.now.to_default_s}: #{item.inspect}"
            ::Rails.logger.info(job_info)
            yield
          end
        end

      end
    end
  end
end

Sidekiq.configure_server do |config|
  config.error_handlers << Proc.new {|ex,ctx_hash| Airbrake.notify(ex, {:parameters=>ctx_hash}) }
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler
    chain.add Sidekiq::Middleware::Server::TaggedLogger
  end
end

Sidekiq.configure_client do |config|
  Sidekiq.logger.level = Logger::WARN
end
