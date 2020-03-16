require './r_socks/tcp_server'

module RSocks
  class Error < StandardError; end
  # Your code goes here...
end

RSocks::TcpServer.new.run!