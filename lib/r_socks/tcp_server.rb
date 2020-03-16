require 'eventmachine'
require './r_socks/connection_handler'

module RSocks
  class TcpServer

    def initialize
      @host = '127.0.0.1'
      @port = 8081
    end

    def run!
      EventMachine.run do
        EventMachine.start_server @host, @port, RSocks::ConnectionHandler
      end
    end
  end
end