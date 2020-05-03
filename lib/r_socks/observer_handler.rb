require 'json'

module RSocks
  class ObserverHandler < EM::Connection

    def initialize(config, cache, redis_service)
      @redis = redis_service.checkout_instance
      @cache = cache
      @config = config
      @server_name = config.server_name
    end

    def receive_data(data)
      begin
        obj = JSON.parse(data, symbolize_names: true)
      rescue => error

      end
    end

    private



  end
end