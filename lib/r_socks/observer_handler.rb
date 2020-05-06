require 'json'

module RSocks
  class ObserverHandler < EM::Connection

    def initialize(config, cache, redis_service)
      @redis = redis_service.checkout_instance
      @cache = cache
      @config = config
      @server_name = config.server_name
      @prefix = @server_name ? "#{@server_name}:" : ''
      @threshold = config.usage_threshold
      @threshold_callback_url =
        config.callback_url.nil? ? nil : URI(config.callback_url)
      @snapshot_existing_in = 15 * 60
    end

    def receive_data(data)
      begin
        obj = JSON.parse(data, symbolize_names: true)
        result = self.send(obj[:cmd], *obj[:args])
        send_data({result: result}.to_json)
        close_connection_after_writing
      rescue => error
        puts error.message
      end
    end

    private

    # ipc method
    def auth(user, pass)
      tmp = @redis.get(key(user, pass))
      return false if tmp.nil? || tmp.empty? || tmp.to_i <= 0
      true
    end

    # ipc method
    def mark(user, pass, usage)
      value = @redis.decrby(key(user, pass), usage)
      snapshot!(user, pass, value)
      true
    end

    def key(user, pass)
      "#{@prefix}#{@server_name}proxy:#{user}-#{pass}"
    end

    def snapshot!(user, pass, value)
      snapshot_key = "#{key(user, pass)}:snapshot"
      snapshot_value = @redis.get(snapshot_key)

      if !snapshot_value.nil? || !snapshot_value&.empty?
        tmp = snapshot_value - value

        if tmp >= @threshold && @threshold_callback_url
          tls = @threshold_callback_url.scheme == 'https'
          EventMachine.connect(
            @threshold_callback_url.host,
            @threshold_callback_url.port,
            RSocks::ThresholdCallbackHandler,
            @threshold_callback_url.path,
            user,
            pass,
            value,
            tls
          )
          @redis.setex(snapshot_key, @snapshot_existing_in, value)
        end

      else
        @redis.setex(snapshot_key, @snapshot_existing_in, value)
      end
    end

  end
end