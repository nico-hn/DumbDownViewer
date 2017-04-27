$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'shellwords'
require 'fileutils'
require "dumb_down_viewer"

module Helpers
  def set_argv(command_line_str)
    ARGV.replace Shellwords.split(command_line_str)
  end

  def self.prepare_test_data
    large_file = "#{__dir__}/data/mammalia/cannot_fly/elephant.txt"
    unless File.exist?(large_file)
      FileUtils.mkdir_p(File.dirname(large_file))
      open(large_file, 'wb') do |file|
        file.print '0' * 15_555_555
      end
    end
  end

  private_class_method :prepare_test_data

  prepare_test_data
end

RSpec.configure do |c|
  c.include Helpers
end
