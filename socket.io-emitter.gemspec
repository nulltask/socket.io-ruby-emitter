# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'socket.io/emitter/version'

Gem::Specification.new do |spec|
  spec.name          = "socket.io-emitter"
  spec.version       = SocketIO::Emitter::VERSION
  spec.authors       = ["nulltask"]
  spec.email         = ["nulltask@gmail.com"]
  spec.summary       = %q{Ruby Socket.IO emitter implementation.}
  spec.homepage      = "https://github.com/nulltask/socket.io-ruby-emitter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"
  spec.add_dependency "msgpack"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
