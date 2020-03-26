require 'r_socks/state_machine'
require 'r_socks/config'
require 'r_socks/http_proxy_response_codes'
require 'r_socks/errors'
require 'r_socks/connection_handler'
require 'r_socks/tcp_server'
# example
#
# server = RSocks::TcpServer.new('127.0.0.1', 8081)
#
# server.config.auth_method = :password
#
# server.run!