require 'r_socks/tcp_server'
# example
#
# server = RSocks::TcpServer.new('127.0.0.1', 8081)
#
# server.config.auth_method = :password
#
# server.run!