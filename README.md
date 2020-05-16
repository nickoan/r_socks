# RSocks
#### project not maintain anymore

#### for https and http proxy please check with [r_proxy](https://github.com/nickoan/r_proxy)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'r_socks'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install r_socks

## Usage

#### use ENV set auth username and password

by default both user and password is: `default`

```
export RSOCKS_USER=some_user_name
export RSOCKS_PASSWORD=some_password
```


run server

```ruby
server = RSocks::TcpServer.new
server.config.auth_method = :password
server.config.proxy_buffer_size = 10 * 1024 * 1024
server.config.proxy_type = :http

# if true then you need attach cert and private key
server.config.enable_ssl = false
# server.config.ssl_private_key = './server_key.txt'
# server.config.ssl_cert = './server_cert.txt'

# start multi process
server.config.instances = 2



server.run!
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nickoan/r_socks.

