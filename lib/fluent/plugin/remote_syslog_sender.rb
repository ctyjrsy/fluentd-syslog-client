require_relative 'remote_syslog_sender/udp_sender'
require_relative 'remote_syslog_sender/tcp_sender'

module RemoteSyslogSender
  VERSION = '1.0.4'

  # def self.new(remote_hostname, remote_port)
  #   UdpSender.new(remote_hostname, remote_port, options)
  # end

  def self.new(remote_hostname, remote_port, options = {})
    protocol = options.delete(:protocol)
    if protocol && protocol.to_sym == :tcp
      # TcpSender.new(remote_hostname, remote_port, options)
      options = {
          tls: true,
          whinyerrors: true,
          packet_size: 1024,
          timeout: nil,
          timeout_exception: false,
          keep_alive: false,
          keep_alive_idle: nil,
          keep_alive_cnt: nil,
          keep_alive_intvl: nil,
          program: "flash_test",
      }
      # options[:ca_file] = options[:ca_file] || "/home/ohm/.rbenv/versions/2.6.1/lib/ruby/gems/2.6.0/gems/fluent-plugin-remote_syslog-1.0.0/certs/logIQ.crt"
      # options[:client_cert] = options[:client_cert] || "/home/ohm/.rbenv/versions/2.6.1/lib/ruby/gems/2.6.0/gems/fluent-plugin-remote_syslog-1.0.0/certs/client-crt.pem"
      # options[:client_key] = options[:client_key] || "/home/ohm/.rbenv/versions/2.6.1/lib/ruby/gems/2.6.0/gems/fluent-plugin-remote_syslog-1.0.0/certs/client-key.pem"
      options[:ca_file] = options[:ca_file] || "/flash/certs/logIQ.crt"
      options[:client_cert] = options[:client_cert] || "/flash/certs/client-crt.pem"
      options[:client_key] = options[:client_key] || "/flash/certs/client-key.pem"

      print "creating TCP Sender ********* \n"
      TcpSender.new(remote_hostname, remote_port, options)
      # TcpSender.new(remote_hostname, remote_port)
    else
      # UdpSender.new(remote_hostname, remote_port, options)
      UdpSender.new(remote_hostname, remote_port, options)
    end
  end
end