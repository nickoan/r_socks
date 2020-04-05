require 'ipaddr'
require 'r_socks/errors'
require 'r_socks/socks5_bit_codes'
require 'r_socks/state_machine'
require 'r_socks/target_connection_handler'
require 'r_socks/authenticator'
require 'r_socks/socks5_proxy_parser'

module RSocks
  class Socks5ProxyParser

    attr_reader :username, :password

    def initialize(state_machine, config, client)
      @state_machine = state_machine
      @auth_method = config.auth_method
      @default_user = ENV['RSOCKS_USER'] || 'default'
      @default_password = ENV['RSOCKS_PASSWORD'] || 'default'
      @authenticator = RSocks::Authenticator.new(config.auth_adaptor)
      @original_addr = nil
      @original_port = nil
      @config = config
      @adaptor = config.auth_adaptor
      @client = client
    end


    def call(data)
      if @state_machine.handshake?
        init_handshake(data)
        return
      end

      if @state_machine.auth?
        passed = @authenticator.auth!(data)
        if passed
          send_data(RSocks::SUCCESS_RESPONSE)
          @state_machine.connect!
          return
        end

        send_data(RSocks::FAILED_RESPONSE)
        return
      end

      if @state_machine.connect?
        connect_request(data)
        @username = @authenticator.username
        @password = @authenticator.password
        return [@addr, @port]
      end

      return send_data(not_accept) unless @state_machine.start?
    end

    private

    def init_handshake(data)

      version, num = data.unpack('CC')

      if version != RSocks::VERSION || num <= 0
        send_data(not_accept)
        close_connection
      end

      position = 'C' * num

      methods = data[2..-1].unpack(position)

      data = nil


      auth_method = @config.auth_method == :password ? PASSWORD_LOGIN : RSocks::NO_AUTH

      if methods.include?(auth_method)

        if auth_method == RSocks::NO_AUTH
          @state_machine.connect!
        elsif auth_method == RSocks::PASSWORD_LOGIN
          @state_machine.auth!
        end

        data = [RSocks::VERSION, auth_method].pack('CC')
      end

      if data.nil?
        send_data(not_accept)
        close_connection
      end

      send_data(data)
    end

    def connect_request(data)
      version, cmd = data.unpack('CC')
      return not_accept if version != RSocks::VERSION

      begin
        @addr, @port, @type = check_sock_cmd(cmd, data[2..-1])
      rescue
        send_data([RSocks::VERSION,RSocks::CONNECT_FAIL].pack('CC'))
        return close_connection
      end

      @state_machine.start!

      send_data([RSocks::VERSION, RSocks::CONNECT_SUCCESS].
        pack('CC') + pack_address_and_port_info(@type))
    end

    def check_sock_cmd(cmd, data)
      raise RSocks::NotSupport unless cmd == RSocks::CMD_CONNECT

      _, addr_type = data.unpack('CC')

      address = nil
      port = nil
      type = nil

      if addr_type == RSocks::ADDR_IPV4
        type = RSocks::ADDR_IPV4
        address, port = parse_address_port(data[2..-1], 4, type)
      elsif addr_type == RSocks::ADDR_IPV6
        type = RSocks::ADDR_IPV6
        address, port = parse_address_port(data[2..-1], 16, type)
      elsif addr_type == RSocks::ADDR_DOMAIN
        type = RSocks::ADDR_DOMAIN
        padding = data[2].unpack('C')[0]
        address, port = parse_address_port(data[3..-1], padding, type)
      end

      [address, port, type]
    end

    def not_accept
      [RSocks::VERSION, RSocks::NOT_ACCEPT].pack('CC')
    end

    def parse_address_port(data, padding, type)
      address = data[0...padding]
      port_start = padding

      @original_port = data[port_start..-1]
      @original_addr = address

      temp = @original_port.unpack('CC')

      port = (temp[0] << 8) | temp[1]

      addr_str = if type == RSocks::ADDR_DOMAIN
                   address
                 else
                   IPAddr.ntop(address)
                 end

      [addr_str, port]
    end

    def pack_address_and_port_info(type)
      addr = @original_addr
      if type == RSocks::ADDR_DOMAIN
        domain_size = [addr.size].pack('C')
        addr = domain_size + @original_addr
      end

      temp = [RSocks::KEEP_ONE_BIT, type]
      temp.pack('C' * temp.size) + addr + @original_port
    end

    def send_data(data)
      @client.send_data(data)
    end

    def close_connection
      @client.close_connection_after_writing
    end
  end
end