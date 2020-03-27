require 'base64'

module RSocks
  class HttpProxyParser

    def initialize(state_machine, config)
      @state_machine = state_machine
      @auth_method = config.auth_method
      @default_user = ENV['RSOCKS_USER'] || 'default'
      @default_password = ENV['RSOCKS_PASSWORD'] || 'default'
      @adaptor = config.auth_adaptor
      @health_check_route = config.health_check_route
    end

    def call(data)
      parser_connect_http(data)
      @state_machine.start!
      [@schema_parse.host, @schema_parse.port]
    end

    private

    def parser_connect_http(data)
      temp = data.split("\r\n")
      host_format_checking(temp.shift)
      generate_header(temp)

      state = auth_user
      raise RSocks::HttpAuthFailed unless state
      state
    end

    def auth_user
      temp = @header['proxy-authorization']
      pattern = /^Basic /
      token = temp.gsub(pattern, '')
      begin
        str = Base64.decode64(token)
        @user, @password = str.split(':')
      rescue
        raise RSocks::HttpNotSupport, "token parse failed #{token}"
      end

      if @adaptor
        return @adaptor.call(@user, @password)
      else
        return @password == @default_password && @user == @default_user
      end
    end

    def host_format_checking(data)
      temp = data.split("\s")
      health_check_request(temp)
      raise RSocks::HttpNotSupport if temp[0] != 'CONNECT'
      @schema_parse = URI("tcp://#{temp[1]}/")
    end

    def generate_header(arr)
      header = {}
      arr.each do |val|
        name, value = val.split(':')
        next if name.nil?
        header[name.strip.downcase] = value&.strip
      end
      @header = header
    end

    def health_check_request(arr_data)
      raise RSocks::HealthChecking if arr_data[0] == 'GET' && @health_check_route == arr_data[1]
    end
  end
end

# state_machine = RSocks::StateMachine.new
# a = RSocks::HttpProxyParser.new(state_machine, RSocks::Config.new)
#
# data = "CONNECT www.google.com.sg:80 HTTP/1.1\r\nHost: www.google.com.sg:80\r\nUser-Agent: Surge macOS/939\r\nConnection: keep-alive\r\nProxy-Connection: keep-alive\r\nProxy-Authorization: Basic ZGVmYXVsdDpkZWZhdWx0\r\n\r\n"
#
# host, port = a.call(data)
#
# puts host
# puts port