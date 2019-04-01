require_relative "../test_helper"

class RemoteSyslogOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::RemoteSyslogOutput).configure(conf)
  end

  # def test_configure
  #   d = create_driver %[
  #     @type remote_syslog
  #     hostname 172.18.0.1
  #     host 172.18.0.1
  #     port 7514
  #     severity debug
  #     program minitest
  #     tag TagKey
  #     tag_key TagKey
  #     tagKey TagKey
  #     tls false
  #     ca_file /flash/certs/logIQ.crt
  #     client_cert /flash/certs/client-crt.pem
  #     client_key /flash/certs/client-key.pem
  #   ]
  #
  #   loggers = d.instance.instance_variable_get(:@senders)
  #   assert_equal loggers, []
  #
  #   assert_equal "172.18.0.1", d.instance.instance_variable_get(:@host)
  #   assert_equal 7514, d.instance.instance_variable_get(:@port)
  #   assert_equal "debug", d.instance.instance_variable_get(:@severity)
  # end

  # def test_write
  #   d = create_driver %[
  #     @type remote_syslog
  #     hostname 172.18.0.1
  #     host 172.18.0.1
  #     port 7514
  #     severity debug
  #     program minitest
  #     tag mPappu
  #     tls true
  #     ca_file /flash/certs/logIQ.crt
  #     client_cert /flash/certs/client-crt.pem
  #     client_key /flash/certs/client-key.pem
  #     <format>
  #       @type single_value
  #       message_key message
  #     </format>
  #   ]
  #
  #   mock.proxy(RemoteSyslogSender::UdpSender).new("172.18.0.1", 7514, whinyerrors: true, program: "minitest", tls: true, ca_file: "/flash/certs/logIQ.crt", client_cert: "/flash/certs/client-crt.pem", client_key: "/flash/certs/client-key.pem") do |sender|
  #   mock.proxy(sender).transmit("foo hello",  facility: "user", severity: "debug", program: "minitest", hostname: "172.18.0.1", tls: true, ca_file: "/flash/certs/logIQ.crt", client_cert: "/flash/certs/client-crt.pem", client_key: "/flash/certs/client-key.pem")
  #   end
  #
  #   d.run do
  #     d.feed("tag", Fluent::EventTime.now, {"message" => "foo hello"})
  #   end
  # end

  def test_write_tcp
    d = create_driver %[
      @type remote_syslog
      hostname 172.18.0.1
      host 172.18.0.1
      port 7514
      severity debug
      program minitest
      tag maderPappu
      tls true
      protocol tcp
      ca_file /flash/certs/logIQ.crt
      client_cert /flash/certs/client-crt.pem
      client_key /flash/certs/client-key.pem
      <format>
        @type single_value
        message_key message
      </format>
    ]

    # any_instance_of(RemoteSyslogSender::TcpSender) do |klass|
    #   mock(klass).connect
    #   print "TCP Sender Connection successful \n"
    # end

    # mock.proxy(RemoteSyslogSender).new("172.18.0.1", 7514, whinyerrors: true, program: "minitest", packet_size: 1024, timeout_exception: false, keep_alive: true, timeout:20, keep_alive_cnt: nil, keep_alive_idle: nil, keep_alive_intvl: nil, tls: true, ca_file: "/flash/certs/logIQ.crt", client_cert: "/flash/certs/client-crt.pem", client_key: "/flash/certs/client-key.pem") do |sender|
    # mock(sender).transmit("172.17.0.1 - - [28/Mar/2019:05:57:26 +0000] \"GET /get HTTP/1.1\" 404 153 \"-\" \"curl/7.47.0\" \"-\"",  facility: "user", timeout: 20, severity: "debug", program: "minitest", hostname: "172.18.0.1", tls: true,  ca_file: "/flash/certs/logIQ.crt", client_cert: "/flash/certs/client-crt.pem", client_key: "/flash/certs/client-key.pem")
    # end

    d.run do
      # d.feed("tag", Fluent::EventTime.now, {"message" => "172.17.0.1 - - [28/Mar/2019:05:57:26 +0000] \"GET /get HTTP/1.1\" 404 153 \"-\" \"curl/7.47.0\" \"-\""})
      d.feed("tag", Fluent::EventTime.now, {"message" => "2019-03-30 15:24:09 +0000 kubernetes.var.log.containers.my-nginx-6f68f94c7b-7jf8p_default_nginx-97cf89cd2236292f5a806a7ef9e2be9396c9771b5b37dd23ea6da2773694d60f.log: {\"log\":\"172.17.0.1 - - [30/Mar/2019:15:24:09 +0000] \"GET /get HTTP/1.1\" 404 153 \"-\" \"curl/7.47.0\" \"-\"\n\",\"stream\":\"stdout\",\"docker\":{\"container_id\":\"97cf89cd2236292f5a806a7ef9e2be9396c9771b5b37dd23ea6da2773694d60f\"},\"kubernetes\":{\"container_name\":\"nginx\",\"namespace_name\":\"default\",\"pod_name\":\"my-nginx-6f68f94c7b-7jf8p\",\"container_image\":\"nginx:latest\",\"container_image_id\":\"docker-pullable://nginx@sha256:98efe605f61725fd817ea69521b0eeb32bef007af0e3d0aeb6258c6e6fe7fc1a\",\"pod_id\":\"6f43eb0b-4577-11e9-95fc-080027b9ad85\",\"labels\":{\"app\":\"my-nginx\",\"pod-template-hash\":\"2924950736\"},\"host\":\"minikube\",\"master_url\":\"https://10.96.0.1:443/api\",\"namespace_id\":\"602a2d71-3f9f-11e8-a424-080027b9ad85\""})
    end
  end
end
