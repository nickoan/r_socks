require 'eventmachine'

module RSocks
  class TcpServer

    def initialize
      @host = '127.0.0.1'
      @port = 9000
    end

    def run!
      EventMachine.run do

      end
    end
  end
end