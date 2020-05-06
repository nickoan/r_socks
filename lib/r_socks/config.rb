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

    def forward_server?
      @store[:forward_server] || false
    end

    def forward_server=(value)
      @store[:forward_server] = value
    end

    def forward_port
      @store[:forward_port]
    end

    def forward_addr
      @store[:forward_addr]
    end

    def forward_port=(value)
      @store[:forward_port] = value.to_i
    end

    def forward_addr=(value)
      @store[:forward_addr] = value.to_s
    end

    def forward_white_list=(arr)
      @store[:white_list] = arr
    end

    def forward_white_list
      @store[:white_list] || []
    end

    # try make an unique name if you share some
    # db or resource between different proxy server
    def server_name=(value)
      @store[:server_name] = value
    end

    def server_name
      @store[:server_name] || ''
    end

    def usage_threshold
      @store[:usage_threshold] || 1 * 1024 * 1024 * 1024
    end

    def usage_threshold=(value)
      @store[:usage_threshold] = value
    end

    def callback_url
      @store[:callback_url]
    end

    def callback_url=(value)
      @store[:callback_url] = value
    end
  end
end