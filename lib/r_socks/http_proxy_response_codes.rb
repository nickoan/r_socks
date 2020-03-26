module RSocks
  module HttpProxyResponseCodes
    SUCCESS = "HTTP/1.1 200 OK\r\n\r\n"
    FAILED_AUTH = "HTTP/1.1 401 Unauthorized\r\n\r\n"
  end
end