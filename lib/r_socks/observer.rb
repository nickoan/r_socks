require 'eventmachine'

module RSocks
  class Observer
    def initialize(config, file)
      @config = config
      @file =file
      @cache_pool = RSocks::CachePool
      @cache_check_interval = 30 #seconds
      @redis_service = RSocks::RedisService.new(config.redis_url)
    end

    def run!
      EventMachine.run do

        EventMachine.start_unix_domain_server(
          @file,
          RSocks::ObserverHandler,
          @config,
          @cache_pool,
          @redis_service
        )

        EventMachine.add_periodic_timer(@cache_check_interval) do
          back_trace = Time.now.to_i - @cache_check_interval
          @cache_pool.clear_with_time(back_trace)
        end

      end
    end
  end
end