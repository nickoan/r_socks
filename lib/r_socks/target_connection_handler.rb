require 'eventmachine'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def initialize(client)
      @client = client
    end

    def post_init
      EM::enable_proxy(self, @client)
    end

    def connection_completed
      close_connection_after_writing
    end

    def receive_data(data)
      @client.send_data(data)
    end

    def proxy_target_unbound
      close_connection
    end

    def unbind
      @client.close_connection_after_writing
    end
  end
end