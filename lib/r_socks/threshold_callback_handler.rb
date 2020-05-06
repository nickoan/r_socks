module RSocks
  class ThresholdCallbackHandler < EM::Connection
    def initialize(route, user, pass, value, tls)
      @http_request = RSocks::HttpPostTemplate.
        new(route).
        create(user, pass, value)
      @response = ''
      @need_tls = tls
    end

    def connection_completed
      start_tls if @need_tls
      set_comm_inactivity_timeout(20)
    end

    def receive_data(data)
      @response += data
    end

    def ssl_handshake_completed
      send_data(@http_request)
    end

    def unbind
      puts @response
    end
  end
end