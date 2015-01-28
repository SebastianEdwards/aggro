# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aggro/version'

Gem::Specification.new do |spec|
  spec.name          = 'aggro'
  spec.version       = Aggro::VERSION
  spec.authors       = ['Sebastian Edwards']
  spec.email         = ['me@sebastianedwards.co.nz']
  spec.summary       = 'Distributed in-memory event-store.'
  spec.description   = ''
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rubocop'

  spec.add_runtime_dependency 'activemodel'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'concurrent-ruby'
  spec.add_runtime_dependency 'consistent-hashing'
  spec.add_runtime_dependency 'invokr'
  spec.add_runtime_dependency 'msgpack'
  spec.add_runtime_dependency 'nio4r'
  spec.add_runtime_dependency 'nn-core'
end
