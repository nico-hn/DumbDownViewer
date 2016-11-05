# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dumb_down_viewer/version'

Gem::Specification.new do |spec|
  spec.name          = "dumb_down_viewer"
  spec.version       = DumbDownViewer::VERSION
  spec.authors       = ["HASHIMOTO, Naoki"]
  spec.email         = ["hashimoto.naoki@gmail.com"]

  spec.summary       = %q{DumbDownViewer (ddv) is a recursive directory listing command with limited functionality.}
  spec.description   = <<-DESCRIPTION
DumbDownViewer (ddv) is a recursive directory listing command with limited functionality.
In some cases, you can use ddv like "tree" command (http://mama.indstate.edu/users/ice/tree/),
even though these commands are not compatible: Several options of "tree" are missing in ddv,
but there are some options that are available only in ddv (such as --copy-to) too.
  DESCRIPTION
  spec.homepage      = "https://github.com/nico-hn/DumbDownViewer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
  spec.add_runtime_dependency "optparse_plus"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
