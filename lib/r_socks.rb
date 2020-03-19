require './r_socks/tcp_server'


server = RSocks::TcpServer.new

server.config.auth_method = :password

server.run!