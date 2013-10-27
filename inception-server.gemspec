# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'inception/version'

Gem::Specification.new do |spec|
  spec.name        = "inception-server"
  spec.version     = Inception::VERSION
  spec.authors     = ["Dr Nic Williams"]
  spec.email       = ["drnicwilliams@gmail.com"]
  spec.description = %q{Create an inception server for Bosh & general inception of new universes}
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
  spec.add_dependency "readwritesettings", "~> 3.0"

  # for inception/providers
  spec.add_dependency "fog"
  spec.add_dependency "cyoi", "~> 0.6.0" # choose your own infrastructure

  # for running cookbooks on inception server
  spec.add_dependency "knife-solo", "~> 0.3.0"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  # gems for the ruby unit & integration tests
  spec.add_development_dependency "rspec"

  # gems for the cookbook tests
  spec.add_development_dependency "test-kitchen", "~> 1.0.0.beta.2"
  spec.add_development_dependency "berkshelf"
end
