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
        @store[:auth_method] = :password
      else
        raise Error, "unknown auth method #{method}"
      end
    end

    def auth_method
      @store[:auth_method] || :password
    end

    def proxy_type=(type)
      if type == :http
        @store[:proxy_type] = :http

      elsif type == :socks5
        @store[:proxy_type] = :socks5
      end
    end

    def proxy_type
      @store[:proxy_type] || :socks5
    end

    def proxy_buffer_size
      @store[:proxy_buffer_size] ||  1024 * 1024 * 10
    end

    def proxy_buffer_size=(value)
      @store[:proxy_buffer_size] = value.to_i
    end

    def health_check_route=(str)
      @store[:health_check_route] = str;
    end

    def health_check_route
      @store[:health_check_route] || '/health'
    end

    def ssl_private_key=(value)
      @store[:ssl_private_key] = value
    end

    def ssl_private_key
      @store[:ssl_private_key]
    end

    def ssl_cert=(value)
      @store[:ssl_cert] = value
    end

    def ssl_cert
      @store[:ssl_cert]
    end

    def enable_ssl=(value)
      @store[:enable_ssl] = value
    end

    def enable_ssl?
      !!@store[:enable_ssl]
    end

    def instances=(number)
      @store[:instance] = number
    end

    def instances
      @store[:instance] || 1
    end

    def unbind_handler=(obj)
      @store[:unbind_handler] = obj
    end

    def unbind_handler
      @store[:unbind_handler]
    end
  end
end