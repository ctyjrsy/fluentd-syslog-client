require_relative "../test_helper"

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
      hostname a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com
      host a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com
      port 7514
      severity debug
      program minitest
      tag TagKey
      tag_key TagKey
      tagKey TagKey
      tls false
      ca_file ../certs/logIQ.crt
      client_cert ../certs/client-crt.pem
      client_key ../certs/client-key.pem
    ]

    loggers = d.instance.instance_variable_get(:@senders)
    assert_equal loggers, []

    assert_equal "a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com", d.instance.instance_variable_get(:@host)
    assert_equal 7514, d.instance.instance_variable_get(:@port)
    assert_equal "debug", d.instance.instance_variable_get(:@severity)
  end

  def test_write
    d = create_driver %[
      @type remote_syslog
      hostname a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com
      host a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com
      port 7514
      severity debug
      program minitest
      tag mPappu
      tls true
      ca_file ../certs/logIQ.crt
      client_cert ../certs/client-crt.pem
      client_key ../certs/client-key.pem
      <format>
        @type single_value
        message_key message
      </format>
    ]

    mock.proxy(RemoteSyslogSender::UdpSender).new("a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com", 7514, whinyerrors: true, program: "minitest", tls: true, ca_file: "../certs/logIQ.crt", client_cert: "../certs/client-crt.pem", client_key: "../certs/client-key.pem") do |sender|
    mock.proxy(sender).transmit("foo hello",  facility: "user", severity: "debug", program: "minitest", hostname: "a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com", tls: true, ca_file: "../certs/logIQ.crt", client_cert: "../certs/client-crt.pem", client_key: "../certs/client-key.pem")
    end

    d.run do
      d.feed("tag", Fluent::EventTime.now, {"message" => "foo hello"})
    end
  end

  def test_write_tcp
    d = create_driver %[
      @type remote_syslog
      hostname a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com
      host a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com
      port 7514
      severity debug
      program minitest
      tag maderPappu
      tls true
      protocol tcp
      ca_file ../certs/logIQ.crt
      client_cert ../certs/client-crt.pem
      client_key ../certs/client-key.pem
      <format>
        @type single_value
        message_key message
      </format>
    ]

    any_instance_of(RemoteSyslogSender::TcpSender) do |klass|
      mock(klass).connect
    end

    mock.proxy(RemoteSyslogSender::TcpSender).new("a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com", 7514, whinyerrors: true, program: "minitest", packet_size: 1024, timeout: nil, timeout_exception: false, keep_alive: false, keep_alive_cnt: nil, keep_alive_idle: nil, keep_alive_intvl: nil, tls: true, ca_file: "../certs/logIQ.crt", client_cert: "../certs/client-crt.pem", client_key: "../certs/client-key.pem") do |sender|
    mock(sender).transmit("foo calling",  facility: "user", severity: "debug", program: "minitest", hostname: "a186d45bc46eb11e983ae0e097e27701-166956918.us-east-1.elb.amazonaws.com", tls: true, ca_file: "../certs/logIQ.crt", client_cert: "../certs/client-crt.pem", client_key: "../certs/client-key.pem")
    end

    d.run do
      d.feed("tag", Fluent::EventTime.now, {"message" => "foo calling"})
    end
  end
end
