require 'socket'
require 'eventmachine'
require 'socket'
require 'r_socks/http_proxy_response_codes'
require 'r_socks/http_proxy_parser'
require 'r_socks/target_connection_handler'
require 'r_socks/socks5_proxy_parser'

module RSocks

  class ConnectionHandler < EM::Connection

    def initialize(config, *args)
      super(*args)
      @state_machine = RSocks::StateMachine.new
      @config = config
      @parser = create_proxy_parser
    end

    def post_init
      begin
        @port, @ip = Socket.unpack_sockaddr_in(get_peername)
      rescue => e
        puts "post_init error: #{e.message}"
        close_connection
      end
    end

    def receive_data(data)

      return send_data(not_accept) if data.nil? || data == ''

      begin
        begin
          @addr, @port = @parser.call(data)
        rescue RSocks::HttpAuthFailed, RSocks::HttpNotSupport
          send_data(RSocks::HttpProxyResponseCodes::FAILED_AUTH)
          close_connection_after_writing
        rescue RSocks::NotSupport
          send_data(RSocks::FAILED_RESPONSE)
          close_connection_after_writing
        end

        return unless @state_machine.start?

        if @target.nil?
          @target = EventMachine.connect(@addr, @port, RSocks::TargetConnectionHandler, self, @config)
          if @config.proxy_type == :http
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

    private

    def create_proxy_parser
      if @config.proxy_type == :http
        return RSocks::HttpProxyParser.new(@state_machine, @config)
      end

      if @config.proxy_type == :socks5
        return RSocks::Socks5ProxyParser.new(@state_machine, @config, self)
      end
    end

  end
end