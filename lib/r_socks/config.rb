module RSocks
  class Config
    def initialize
      @store = {}
    end

    def auth_adaptor=(adaptor)
      @store[:adaptor] = adaptor
    end

    def auth_adaptor
      @store[:adaptor]
    end

    def auth_method=(method)
      if method == :no_auth
        @store[:auth_method] = RSocks::NO_AUTH
      elsif method == :password
        @store[:auth_method] = RSocks::PASSWORD_LOGIN

      else
        raise Error, "unknown auth method #{method}"
      end
    end

    def auth_method
      @store[:auth_method]
    end
  end
end