module RSocks

  class Authenticator

    def initialize(adaptor = nil)
      @default_user = ENV['RSOCKS_USER'] || 'default'
      @default_password = ENV['RSOCKS_PASSWORD'] || 'default'
      @adaptor = adaptor
    end

    def auth!(data)
      return false if data.unpack('C')[0] != RSocks::AUTH_HEADER
      validate(data[1..-1])
    end

    private

    def validate(data)
      username, remain = get_username(data)
      password = get_password(remain)

      if @adaptor.nil?
        username == @default_user && password == @default_password
      else
        @adaptor.call(username, password)
      end
    end

    def get_username(data)
      name_size = data.unpack('C')[0]
      username = data[1..name_size]
      [username, data[(name_size + 1)..-1]]
    end

    def get_password(data)
      password_size = data.unpack('C')[0]
      password = data[1..password_size]
      password
    end
  end
end