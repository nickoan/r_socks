require 'socket'
require 'eventmachine'
require 'socket'
require 'ipaddr'
require './r_socks/errors'
require './r_socks/socks5_bit_codes'
require './r_socks/state_machine'
require './r_socks/target_connection_handler'

module RSocks

  class ConnectionHandler < EM::Connection
    def post_init
      @port, @ip = Socket.unpack_sockaddr_in(get_peername)
      puts "new #{@ip}:#{@port} connected."
      @state_machine = RSocks::StateMachine.new
      @original_addr = nil
      @original_port = nil
    end
    # sample \x05\x01\x00\x03\ngoogle.com\x00P

    def receive_data(data)
      if @state_machine.handshake?
        return init_handshake(data)
      end

      if @state_machine.auth?
        #working on
      end

      if @state_machine.connect?
        connect_request(data)
        @target = EventMachine.attach(@current_socket, RSocks::TargetConnectionHandler)
        @target.source_io = self
        return
      end

      return send_data(not_accept) unless @state_machine.start?
      @target.send_data(data)
    end

    def unbind
      puts "#{@ip}:#{@port} had disconnected."
      if @current_socket && !@current_socket.closed?
        @current_socket.close
      end
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

      if methods.include?(PASSWORD_LOGIN)
        @state_machine.auth!
        data = [RSocks::VERSION, PASSWORD_LOGIN].pack('CC')
      end

      if methods.include?(NO_AUTH)
        @state_machine.connect!
        data = [RSocks::VERSION, NO_AUTH].pack('CC')
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
        addr, port, type = check_sock_cmd(cmd, data[2..-1])
        @current_socket = TCPSocket.new(addr, port)
      rescue
        send_data([RSocks::VERSION,RSocks::CONNECT_FAIL].pack('CC'))
        return close_connection
      end

      @state_machine.start!

      send_data([RSocks::VERSION, RSocks::CONNECT_SUCCESS].
        pack('CC') + pack_address_and_port_info(type))
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

  end
end