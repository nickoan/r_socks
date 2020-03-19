require 'eventmachine'

module RSocks
  class TargetConnectionHandler < EM::Connection

    def source_io=(io)
      @source_io = io
    end

    def receive_data(data)
      @source_io.send_data(data)
    end

    def unbind
      @source_io.close_connection
    end
  end
end