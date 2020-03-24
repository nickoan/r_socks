require 'eventmachine'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def initialize(client, data)
      @client = client
      @init_data = data
    end

    def post_init
      proxy_incoming_to(@client,60000)
    end

    def connection_completed
      send_data @init_data
      @init_data = nil
    end

    def proxy_target_unbound
      close_connection
    end

    def unbind
      @client.close_connection_after_writing
    end
  end
end