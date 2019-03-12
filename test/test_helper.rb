require 'bundler/setup'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
$:.unshift File.expand_path('../lib/fluent/plugin', __FILE__)
$:.unshift File.expand_path('../lib/fluent/plugin/remote_syslog_sender', __FILE__)

require "fluent/test"
require 'fluent/test/driver/output'

require 'test/unit/rr'
require_relative '../lib/fluent/plugin/remote_syslog_sender'
require_relative '../lib/fluent/plugin/out_remote_syslog'

unless ENV['BUNDLE_GEMFILE']
  require 'rubygems'
  require 'bundler'
  Bundler.setup
  Bundler.require
end