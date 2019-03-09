require_relative "../test_helper"
# require_relative "../../lib/fluent/plugin//remote_syslog_sender"
# require_relative "../../lib/fluent/plugin/out_remote_syslog"
# require_relative "../../lib/fluent/plugin/remote_syslog_sender/tcp_sender"
# require_relative "../../lib/fluent/plugin/remote_syslog_sender/udp_sender"
# require_relative "../../lib/fluent/plugin/remote_syslog_sender/sender"


class RemoteSyslogOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::RemoteSyslogOutput).configure(conf)
  end

  def test_configure
    d = create_driver %[
      @type remote_syslog
      hostname a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com
      host a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com
      port 7514
      severity debug
      program minitest
      tag TagKey
      tag_key TagKey
      tagKey TagKey
      tls false
      ca_file /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt
      client_cert /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem
      client_key /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key
    ]

    loggers = d.instance.instance_variable_get(:@senders)
    assert_equal loggers, []

    assert_equal "a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com", d.instance.instance_variable_get(:@host)
    assert_equal 7514, d.instance.instance_variable_get(:@port)
    assert_equal "debug", d.instance.instance_variable_get(:@severity)
  end

  def test_write
    d = create_driver %[
      @type remote_syslog
      hostname a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com
      host a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com
      port 7514
      severity debug
      program minitest
      tag mPappu
      tls true
      ca_file /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt
      client_cert /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem
      client_key /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key
      <format>
        @type single_value
        message_key message
      </format>
    ]

    mock.proxy(RemoteSyslogSender::UdpSender).new("a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com", 7514, whinyerrors: true, program: "minitest", tls: true, ca_file: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt", client_cert: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem", client_key: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key") do |sender|
      mock.proxy(sender).transmit("foo",  facility: "user", severity: "debug", program: "minitest", hostname: "a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com", tls: true, ca_file: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt", client_cert: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem", client_key: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key")
    end

    d.run do
      d.feed("tag", Fluent::EventTime.now, {"message" => "foo"})
    end
  end

  def test_write_tcp
    d = create_driver %[
      @type remote_syslog
      hostname a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com
      host a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com
      port 7514
      severity debug
      program minitest
      tag maderPappu
      tls true
      protocol tcp
      ca_file /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt
      client_cert /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem
      client_key /home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key
      <format>
        @type single_value
        message_key message
      </format>
    ]

    any_instance_of(RemoteSyslogSender::TcpSender) do |klass|
      mock(klass).connect
    end

    mock.proxy(RemoteSyslogSender::TcpSender).new("a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com", 7514, whinyerrors: true, program: "minitest", packet_size: 1024, timeout: nil, timeout_exception: false, keep_alive: false, keep_alive_cnt: nil, keep_alive_idle: nil, keep_alive_intvl: nil, tls: true, ca_file: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt", client_cert: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem", client_key: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key") do |sender|
      mock(sender).transmit("foo",  facility: "user", severity: "debug", program: "minitest", hostname: "a74b9a742424311e9a2550e408a33ee8-1905025207.us-east-1.elb.amazonaws.com", tls: true, ca_file: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/logIQ.crt", client_cert: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.pem", client_key: "/home/ohm/work/repo/src/bitbucket.org/logiqcloud/flash/client-crt.key")
    end

    d.run do
      d.feed("tag", Fluent::EventTime.now, {"message" => "foo"})
    end
  end
end
