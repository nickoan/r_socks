require 'eventmachine'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def initialize(client, request)
      @client, @request = client, request
    end

    def post_init
      EM::enable_proxy(self, @client)
    end

    def connection_completed
      send_data @request
    end

    def proxy_target_unbound
      close_connection
    end

    def unbind
      @client.close_connection_after_writing
    end
  end
end