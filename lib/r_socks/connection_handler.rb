require 'socket'
require 'eventmachine'
require 'socket'
require 'r_socks/http_proxy_response_codes'
require 'r_socks/http_proxy_parser'
require 'r_socks/target_connection_handler'

module RSocks

  class ConnectionHandler < EM::Connection

    def initialize(config, *args)
      super(*args)
      @state_machine = RSocks::StateMachine.new
      @original_addr = nil
      @original_port = nil
      # @authenticator = RSocks::Authenticator.new(config.auth_adaptor)
      @config = config
    end

    def post_init
      begin
        @port, @ip = Socket.unpack_sockaddr_in(get_peername)
      rescue => e
        puts "post_init error: #{e.message}"
        close_connection
      end
    end
    # sample \x05\x01\x00\x03\ngoogle.com\x00P

    def receive_data(data)

      return send_data(not_accept) if data.nil? || data == ''

      begin

        if !@state_machine.start?

          parser = RSocks::HttpProxyParser.new(@state_machine, @config)

          begin
            @addr, @port = parser.call(data)
          rescue
            send_data(RSocks::HttpProxyResponseCodes::FAILED_AUTH)
            close_connection_after_writing
          end

          return unless @state_machine.start?

          if @target.nil?
            @target = EventMachine.connect(@addr, @port, RSocks::TargetConnectionHandler, self, @config)
            send_data(RSocks::HttpProxyResponseCodes::SUCCESS)
          end
        end
        proxy_incoming_to(@target, @config.proxy_buffer_size)
      rescue => error
        puts "Error at #{@ip}:#{@port}, message: #{data}, error: #{error.message}"
        puts error.backtrace
      end
    end

    def unbind
      stop_proxying
      @target.close_connection_after_writing if @target
    end

    def proxy_target_unbound
      close_connection
    end
  end
end