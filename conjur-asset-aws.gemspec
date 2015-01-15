# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'conjur-asset-aws-version'

Gem::Specification.new do |spec|
  spec.name          = "conjur-asset-aws"
  spec.version       = Conjur::Asset::AWS::VERSION
  spec.authors       = ["Kevin Gilpin"]
  spec.email         = ["kgilpin@conjur.net"]
  spec.summary       = %q{Conjur plugin for integrating with AWS}
  spec.homepage      = "https://github.com/conjurinc/conjur-asset-aws"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "conjur-api"
  spec.add_dependency "conjur-asset-host-factory"
  spec.add_dependency "aws-sdk-v1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "conjur-cli"
end
