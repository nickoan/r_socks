require 'socket'
require 'eventmachine'
require 'socket'

module RSocks
  class ConnectionHandler < EM::Connection

    def post_init
      @port, @ip = Socket.unpack_sockaddr_in(get_peername)
      puts "new #{@ip}:#{@port} connected."
    end


    # sample \x05\x01\x00\x03\ngoogle.com\x00P

    def receive_data(data)
      p data
      verison, num, method = data.unpack('CCC')
      send_data [verison, method].pack('CC')
      # working on
    end

    def unbind
      puts "#{@ip}:#{@port} had disconnected."
    end
  end
end