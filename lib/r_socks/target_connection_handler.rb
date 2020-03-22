require 'eventmachine'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def initialize(client)
      @client = client
    end

    def receive_data(data)
      @client.send_data(data)
    end

    def unbind
      @client.close_connection_after_writing
    end
  end
end