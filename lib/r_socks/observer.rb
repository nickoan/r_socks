require 'eventmachine'

module RSocks
  class Observer
    def initialize(config, file)
      @config = config
      @file =file
      @cache_pool = RSocks::CachePool
      @cache_check_interval = 30 #seconds
    end

    def run!
      EventMachine.run do
        EventMachine.start_unix_domain_server(@file)
        EventMachine.add_periodic_timer(@cache_check_interval) do
          @cache_pool.del_with_condition do |value|
            value['expire_at'] < Time.now.to_i
          end
        end
      end
    end
  end
end