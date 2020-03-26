# RSocks

this is a socks5 server base on Eventmachine.

can be using as socks5 proxy server side.

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
require 'r_socks'

server = RSocks::TcpServer.new('127.0.0.1', 8081)

server.config.auth_method = :password
server.config.proxy_type = :http # default proxy_type = socks5

server.run!
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nickoan/r_socks.

