require 'fluent/output'
require 'fluent/formatter'
require 'fluent/config/error'
require 'socket'
require 'openssl'
require 'json'
require_relative 'remote_syslog_sender/tcp_sender'
require_relative 'remote_syslog_sender/udp_sender'

module Fluent
  module Plugin
      class RemoteSyslogOutput < BufferedOutput
        Fluent::Plugin.register_output("remote_syslog", self)

        helpers :formatter, :inject, :compat_parameters

        config_param :hostname, :string, :default => ""

        config_param :host, :string, :default => nil
        config_param :tag, :string, :default => nil
        config_param :tag_key, :string, :default => nil
        config_param :tagKey, :string, :default => nil
        config_param :port, :integer, :default => 514
        config_param :host_with_port, :string, :default => nil

        config_param :facility, :string, :default => "user"
        config_param :severity, :string, :default => "notice"
        config_param :program, :string, :default => "fluentd"

        config_param :protocol, :enum, list: [:udp, :tcp], :default => :udp
        config_param :tls, :bool, :default => false
        config_param :ca_file, :string, :default => nil
        config_param :verify_mode, :integer, default: nil
        config_param :packet_size, :size, default: 1024
        config_param :timeout, :time, default: nil
        config_param :timeout_exception, :bool, default: false

        config_param :keep_alive, :bool, :default => false
        config_param :keep_alive_idle, :integer, :default => nil
        config_param :keep_alive_cnt, :integer, :default => nil
        config_param :keep_alive_intvl, :integer, :default => nil

        # For SSL
        config_param :client_cert, :string, default: nil
        config_param :client_key, :string, default: nil

        config_section :buffer do
          config_set_default :flush_mode, :interval
          config_set_default :flush_interval, 5
          config_set_default :flush_thread_interval, 0.5
          config_set_default :flush_thread_burst_interval, 0.5


        end

        config_section :format do
          config_set_default :@type, 'ltsv'
        end

        def initialize
          super
          print "out remote syslog sender init \n"
        end

        def configure(conf)
          compat_parameters_convert(conf, :buffer, :inject, default_chunk_key: "time")
          super
          print "inside configure \n"
          print conf
          if @host.nil? && @host_with_port.nil?
            raise ConfigError, "host or host_with_port is required"
          end

          @formatter = formatter_create
          unless @formatter.formatter_type == :text_per_line
            raise ConfigError, "formatter_type must be text_per_line formatter"
          end

          # validate_target = "host=#{@host}/port=#{@port}/hostname=#{@hostname}/facility=#{@facility}/severity=#{@severity}/program=#{@program}/tag=#{@tag}/tag_key=#{@tag_key}/tagKey=#{@tagKey}"
          # placeholder_validate!(:remote_syslog, validate_target)
          validate_target = "host=#{@host}/host_with_port=#{@host_with_port}/hostname=#{@hostname}/facility=#{@facility}/severity=#{@severity}/program=#{@program}"
          placeholder_validate!(:remote_syslog, validate_target)
          print "validated the connection"
          @senders = []
        end

        def multi_workers_ready?
          true
        end

        def close
          print " in close"
          super
          @senders.each { |s| s.close if s }
          @senders.clear
        end

        def format(tag, time, record)
          print "in format \n"
          r = inject_values_to_record(tag, time, record)
          @formatter.format(tag, time, r)
        end


        def write(chunk)
          print "in write \n"
          return if chunk.empty?
          print " chunk non empty \n"
          host = @host # extract_placeholders(@host, chunk.metadata)
          port = @port
          data = chunk.read
          print data
          print host+"\n"
          print port
          print "\n"

          # if @host_with_port
          #   host, port = extract_placeholders(@host_with_port, chunk.metadata).split(":")
          # end

          host_with_port = "#{host}:#{port}"

          Thread.current[host_with_port] = create_sender(host, port)
          sender = Thread.current[host_with_port]

          facility = @facility #extract_placeholders(@facility, chunk.metadata)
          severity = @severity #extract_placeholders(@severity, chunk.metadata)
          program = @program #extract_placeholders(@program, chunk.metadata)
          hostname = @hostname #extract_placeholders(@hostname, chunk.metadata)

          print "facility "+facility+ " severity "+severity+" program "+program + " hostname "+hostname+" \n"
          packet_options = {facility: facility, severity: severity, program: program}
          packet_options[:hostname] = hostname unless hostname.empty?
          packet_options[:tls] = true
          # packet_options[:timeout] = nil
          packet_options[:ca_file]= "/fluentd/certs/logIQ.crt"
          packet_options[:client_cert]= "/fluentd/certs/client-crt.pem"
          packet_options[:client_key]= "/fluentd/certs/client-key.pem"

          begin
            chunk.open do |io|
              io.each_line do |msg|
                if !msg.nil? && !msg.empty?
                  print " sending msg: "+msg.chomp!+"\n"
                  sender.transmit(msg, packet_options)
                else
                  print "message was empty"
                end
                # result = sender.write msg
                # print result+" \n"
              end
            end
          rescue
            if Thread.current[host_with_port]
              Thread.current[host_with_port].close
              @senders.delete(Thread.current[host_with_port])
              Thread.current[host_with_port] = nil
            end
            raise
          end
        end

        def start
          print " in start \n"
          super
        end

        def shutdown
          print " in shutdown \n"
          super
        end

        def create_sender(host, port)
          print " in create sender \n"
          print @timeout
          print "\n"
          print @tls
          print "\n"

          options = {
              tls: @tls,
              whinyerrors: true,
              packet_size: @packet_size,
              timeout: 20,
              timeout_exception: @timeout_exception,
              keep_alive: true,
              keep_alive_idle: @keep_alive_idle,
              keep_alive_cnt: @keep_alive_cnt,
              keep_alive_intvl: @keep_alive_intvl,
              program: @program,
              # protocol: "tcp",
          }
          # options[:ca_file] = @ca_file if @ca_file
          # options[:client_cert] = @client_cert if @client_cert
          # options[:client_key] = @client_key if @client_key
          options[:verify_mode] = @verify_mode if @verify_mode

          # options = {
          #     tls: true,
          #     whinyerrors: true,
          #     packet_size: 1024,
          #     timeout: nil,
          #     timeout_exception: false,
          #     keep_alive: false,
          #     keep_alive_idle: nil,
          #     keep_alive_cnt: nil,
          #     keep_alive_intvl: nil,
          #     program: "flash_test",
          # }
          options[:ca_file] = options[:ca_file] || "/fluentd/certs/logIQ.crt"
          options[:client_cert] = options[:client_cert] || "/fluentd/certs/client-crt.pem"
          options[:client_key] = options[:client_key] || "/fluentd/certs/client-key.pem"

          if @protocol == :tcp
            print "creating tcp sender*******************"
            sender = RemoteSyslogSender::TcpSender.new(
              host,
              port,
              options
            )
          else
            print "creating udp sender"
            sender = RemoteSyslogSender::UdpSender.new(
              host,
              port,
              whinyerrors: true,
              program: @program,
              tls: true,
              ca_file: @ca_file,
              client_cert: @client_cert,
              client_key: @client_key

            )
          end
          @senders << sender
          sender
        end
      end
  end
end