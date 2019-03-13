require_relative "../test_helper"

class TestRemoteSyslogSender < Test::Unit::TestCase
  def setup
    @server_port = rand(50000) + 1024
    @socket = UDPSocket.new
    @socket.bind('127.0.0.1', @server_port)

    @tcp_server = TCPServer.open('127.0.0.1', 9980)
    @tcp_server_port = @tcp_server.addr[1]

    # @tcp_server_wait_thread = Thread.start do
    #   @tcp_server.accept
    # end
  end

  def teardown
    @socket.close
    @tcp_server.close
  end

  # def test_sender
  #   @sender = RemoteSyslogSender.new('127.0.0.1', @server_port)
  #   @sender.write "This is a test"
  #
  #   message, _ = *@socket.recvfrom(1024)
  #   assert_match(/This is a test/, message)
  # end
  #
  # def test_sender_long_payload
  #   @sender = RemoteSyslogSender.new('127.0.0.1', @server_port, packet_size: 10240)
  #   @sender.write "abcdefgh" * 1000
  #
  #   message, _ = *@socket.recvfrom(10240)
  #   assert_match(/#{"abcdefgh" * 1000}/, message)
  # end

  # def test_sender_tcp
  #   @sender = RemoteSyslogSender.new('127.0.0.1', @tcp_server_port, protocol: :tcp)
  #   @sender.write "This is a test"
  #   sock = @tcp_server_wait_thread.value
  #
  #   message, _ = *sock.recvfrom(1024)
  #   assert_match(/This is a test/, message)
  # end

  def test_sender_tcp_nonblock
    100.times do |n|
      n += 1
      @sender = RemoteSyslogSender.new('a9ea88e75449611e9baa40e0f460a80c-245806492.us-east-1.elb.amazonaws.com', 7514, protocol: :tcp, timeout: 20)
      result = @sender.write "This is a test "
      assert_match("This is a test ", result.map { |i| "'" + i.to_s + "'" }.join(","))
    end
  end

  # def test_sender_multiline
  #   @sender = RemoteSyslogSender.new('127.0.0.1', @server_port)
  #   @sender.write "This is a test\nThis is the second line"
  #
  #   message, _ = *@socket.recvfrom(1024)
  #   assert_match(/This is a test/, message)
  #
  #   message, _ = *@socket.recvfrom(1024)
  #   assert_match(/This is the second line/, message)
  # end
end
