require 'eventmachine'
require 'r_socks/http_proxy_response_codes'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def initialize(client, config)
      @client = client
      @config = config
    end

    def post_init
      proxy_incoming_to(@client, @config.proxy_buffer_size)
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