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
      @force_expire = 20 # seconds
    end

    def post_init
      begin
        if @config.enable_ssl?
          start_tls(
            private_key_file: @config.ssl_private_key,
            cert_chain_file: @config.ssl_cert
          )
        end
        @port, @ip = Socket.unpack_sockaddr_in(get_peername)

        white_list = @config.forward_white_list
        if !white_list.empty? && !white_list.include?(@ip.to_s)
          raise Error, "#{@ip} not in white list"
        end

        @timer = EventMachine.add_timer(20) do
          self.close_connection(false)
          @timer = nil
        end
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

        rescue RSocks::HealthChecking
          send_data(RSocks::HttpProxyResponseCodes::SUCCESS)
          close_connection_after_writing
        end

        return unless @state_machine.start?

        if @config.forward_server? && @config.proxy_type == :http
          @target = EventMachine.connect(@config.forward_addr,
                                         @config.forward_port,
                                         RSocks::TargetConnectionHandler,
                                         self,
                                         @config,
                                         data)
          @target.assign_user_and_password(@username, @password)
        end

        @username = @parser.username
        @password = @parser.password
        if @target.nil?
          @target = EventMachine.connect(@addr, @port, RSocks::TargetConnectionHandler, self, @config)
          @target.assign_user_and_password(@username, @password)
        end
      rescue => error
        puts "Error at #{@ip}:#{@port}, message: #{data}, error: #{error.message}"
        puts error.backtrace
      end
    end

    def unbind

      EventMachine.cancel_timer(@timer) if @timer

      stop_proxying
      @target.close_connection_after_writing if @target

      if @config.unbind_handler
        @config.unbind_handler.call(get_proxied_bytes, @username, @password)
      end
    end

    def proxy_target_unbound
      close_connection
    end

    private

    def forward_request
      @port = @config.forward_port
      @addr = @config.forward_addr
    end

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