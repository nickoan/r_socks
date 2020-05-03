require 'redis'

module RSocks
  class RedisService
    # redis://:p4ssw0rd@10.0.1.1:6380/15
    def initialize(url)
      @redis_url = url
    end

    def checkout_instance
      Redis.new(url: @redis_url)
    end
  end
end