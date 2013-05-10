# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inception/version'

Gem::Specification.new do |spec|
  spec.name        = "inception"
  spec.version     = Inception::VERSION
  spec.authors     = ["Dr Nic Williams"]
  spec.email       = ["drnicwilliams@gmail.com"]
  spec.description = %q{Create an inception server for Bosh}
  spec.summary     = %q{CLI, with chef recipes, for creating and preparing an inception server for deploying/developing a Bosh universe.}
  spec.homepage    = ""
  spec.license     = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "highline"
  spec.add_dependency "escape"
  spec.add_dependency "json"
  spec.add_dependency "settingslogic", "~> 2.0.9" # need to_nested_hash method

  # for bosh/providers
  spec.add_dependency "fog"

  # for running cookbooks on inception server
  spec.add_dependency "knife-solo", "~> 0.3.0.pre"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  # gems for the ruby unit & integration tests
  spec.add_development_dependency "rspec"

  # gems for the cookbook tests
  spec.add_development_dependency "test-kitchen", "~> 1.0.0.alpha.6"
  spec.add_development_dependency "berkshelf"
end
