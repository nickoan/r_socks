require 'socket'
require 'eventmachine'
require 'socket'
require './r_socks/state_machine'

module RSocks

  VERSION = 0x05
  NOT_ACCEPT = 0xFF

  PASSWORD_LOGIN = 0x02
  NO_AUTH = 0x00

  class ConnectionHandler < EM::Connection
    def post_init
      @port, @ip = Socket.unpack_sockaddr_in(get_peername)
      puts "new #{@ip}:#{@port} connected."
      @state_machine = RSocks::StateMachine.new
    end


    # sample \x05\x01\x00\x03\ngoogle.com\x00P

    def receive_data(data)
      p data
      if @state_machine.handshake?
        send_data(init_handshake(data))
      end

      if @state_machine.auth?
        #working on
      end

      if @state_machine.start?
        #working on
      end
      # working on
    end

    def unbind
      puts "#{@ip}:#{@port} had disconnected."
    end

    private

    def init_handshake(data)

      version, num = data.unpack('CC')

      if version != RSocks::VERSION || num <= 0
        return [RSocks::VERSION, RSocks::NOT_ACCEPT].pack('CC')
      end

      position = 'C' * num

      methods = data[2..-1].unpack(position)

      if methods.include?(PASSWORD_LOGIN)
        @state_machine.auth!
        return [RSocks::VERSION, PASSWORD_LOGIN].pack('CC')
      end

      if methods.include?(NO_AUTH)
        @state_machine.start!
        return [RSocks::VERSION, NO_AUTH].pack('CC')
      end

      return [RSocks::VERSION, RSocks::NOT_ACCEPT].pack('CC')
    end
  end
end