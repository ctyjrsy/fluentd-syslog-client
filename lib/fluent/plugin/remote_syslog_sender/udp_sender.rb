require 'socket'
require 'syslog_protocol'
require_relative './sender'

module RemoteSyslogSender
  class UdpSender < Sender
    def initialize(remote_hostname, remote_port, options = {})
      super
      print "UdpSender ********************************"
      @socket = UDPSocket.new
    end

    private

    def send_msg(payload)
      @socket.send(payload, 0, @remote_hostname, @remote_port)
    end
  end
end
