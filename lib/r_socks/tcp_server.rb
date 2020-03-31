require 'eventmachine'
require 'r_socks/connection_handler'
require 'r_socks/config'

module RSocks
  class TcpServer

    attr_reader :config

    def initialize(host = '127.0.0.1', port = 8081)
      @host = host
      @port = port
      @config = RSocks::Config.new
    end

    def run!
      begin
        start_tcp_server
      rescue Interrupt
        puts "\nr_socks TPC main server closed now...."
      end
    end

    private

    def start_tcp_server

      if @config.instances > 1
        spawn_process(@config.instances.to_i)
      else
        EventMachine.run do
          EventMachine.start_server @host, @port, RSocks::ConnectionHandler, @config
        end
      end
    end

    def attach_and_start_server(server)
      EventMachine.run do
        EventMachine.attach_server(server, RSocks::ConnectionHandler, @config)
      end
    end

    def spawn_process(number)

      server = TCPServer.new(@host, @port)
      pids = []

      number.times do |i|
        pids << Process.fork do
          puts "start r_socks instance @#{i}"
          Signal.trap("TERM") { exit! }
          begin
            attach_and_start_server(server)
          rescue Interrupt
            puts "r_socks TPC server instance @#{i} closed now...."
          rescue => e
            puts "r_socks instance @#{i} exit with exception: \r\n#{e.message}"
          end
        end
      end

      # if main process run in backgourd and has been killed
      # then all sub-process should term
      at_exit do
        term_all_sub_process(pids)
      end

      Process.waitall
    end

    def term_all_sub_process(pids)
      pids.each do |id|
        next unless id
        Process.kill("TERM", id)
      end
    end
  end
end