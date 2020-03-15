require 'socket'
require 'eventmachine'

module RSocks
  class ConnectionHandler < EM::Connection

    def post_init
      @port, @ip = Socket.unpack_sockaddr_in(get_peername)
      puts "new #{@ip}:#{@port} connected."
    end

    def receive_data(data)
      # working on
    end

    def unbind
      puts "#{@ip}:#{@port} had disconnected."
    end
  end
end