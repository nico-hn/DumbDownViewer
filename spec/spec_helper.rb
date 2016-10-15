$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'shellwords'
require "dumb_down_viewer"

module Helpers
  def set_argv(command_line_str)
    ARGV.replace Shellwords.split(command_line_str)
  end
end

RSpec.configure do |c|
  c.include Helpers
end
