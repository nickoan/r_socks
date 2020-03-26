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
        @store[:auth_method] = :no_auth
      elsif method == :password
        @store[:auth_method] = :auth_method
      else
        raise Error, "unknown auth method #{method}"
      end
    end

    def auth_method
      @store[:auth_method] || :password
    end

    def proxy_buffer_size
      @store[:proxy_buffer_size] ||  1024 * 1024 * 10
    end

    def proxy_buffer_size=(value)
      @store[:proxy_buffer_size] = value.to_i
    end
  end
end