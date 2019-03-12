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
      options[:ca_file] = "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/certs/logIQ.crt"
      options[:client_cert] = "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/certs/client-crt.pem"
      options[:client_key] = "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/certs/client-key.pem"
      TcpSender.new(remote_hostname, remote_port, options)
      # TcpSender.new(remote_hostname, remote_port)
    else
      # UdpSender.new(remote_hostname, remote_port, options)
      UdpSender.new("100.96.1.5", 7514, whinyerrors: true, program: "minitest", tls: true, ca_file: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt", client_cert: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem", client_key: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key")
    end
  end
end