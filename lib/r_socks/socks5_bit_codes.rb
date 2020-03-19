module RSocks
  VERSION = 0x05
  NOT_ACCEPT = 0xFF

  PASSWORD_LOGIN = 0x02
  NO_AUTH = 0x00

  AUTH_HEADER = 0x01

  KEEP_ONE_BIT = 0x00

  CMD_CONNECT = 0x01
  CMD_BIND = 0x02
  CMD_UDP = 0x03

  ADDR_IPV4 = 0x01
  ADDR_IPV6 = 0x04
  ADDR_DOMAIN = 0x03


  CONNECT_FAIL = 0x01
  CONNECT_SUCCESS = 0x00

  SUCCESS_RESPONSE = [AUTH_HEADER, 0x00].pack('CC')
  FAILED_RESPONSE = [AUTH_HEADER, 0x01].pack('CC')
end