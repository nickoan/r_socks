require 'eventmachine'
require './r_socks/connection_handler'

module RSocks
  class TcpServer

    def initialize(host = '127.0.0.1', port = 8081)
      @host = host
      @port = port
    end

    def run!
      begin
        start_tcp_server
      rescue Interrupt
        puts ""
        puts "RSocks TPC server closed now...."
      end
    end

    private

    def start_tcp_server
      EventMachine.run do
        EventMachine.start_server @host, @port, RSocks::ConnectionHandler
      end
    end
  end
end