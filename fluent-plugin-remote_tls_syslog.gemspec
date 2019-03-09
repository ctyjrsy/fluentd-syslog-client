# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-remote_tls_syslog"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["City Jrsy"]
  spec.email         = ["ctyjrsy@yahoo.com"]
  spec.summary       = %q{Fluentd output plugin for remote tls syslog}
  spec.description   = spec.description
  spec.homepage      = "https://github.com/ctyjrsy/fluent-syslog-client"
  spec.license       = "MIT"

  # spec.files         = `git ls-files -z`.split("\x0")
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  # spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'syslog_protocol'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit"
  spec.add_development_dependency "test-unit-rr"

  spec.add_runtime_dependency "fluentd"
end
