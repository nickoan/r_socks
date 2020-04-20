require 'eventmachine'
require 'r_socks/http_proxy_response_codes'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def initialize(client, config, connect_data = nil)
      @client = client
      @config = config
      @connect_data = connect_data
      @forward_connection = !@connect_data.nil?
      @forward_success = false
    end

    def assign_user_and_password(username, password)
      @username = username
      @password = password
    end

    def connection_completed
      if @connect_data
        send_data(@connect_data)
      else
        response_proxy_connect_ready
      end
    end

    def receive_data(data)
      if @forward_connection && !@forward_success
        if data == RSocks::HttpProxyResponseCodes::SUCCESS
          @forward_success = true
          response_proxy_connect_ready
        end
      end
    end

    def proxy_target_unbound
      close_connection
    end

    def unbind
      @client.close_connection_after_writing
      if @config.unbind_handler
        @config.unbind_handler.call(get_proxied_bytes, @username, @password)
      end
    end

    private

    def response_proxy_connect_ready
      if @config.proxy_type == :http
        @client.send_data(RSocks::HttpProxyResponseCodes::SUCCESS)
      end
      @client.proxy_incoming_to(self, @config.proxy_buffer_size)
      proxy_incoming_to(@client, @config.proxy_buffer_size)
    end
  end
end