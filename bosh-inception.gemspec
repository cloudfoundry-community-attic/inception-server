# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bosh/inception/version'

Gem::Specification.new do |spec|
  spec.name        = "bosh-inception"
  spec.version     = Bosh::Inception::VERSION
  spec.authors     = ["Dr Nic Williams"]
  spec.email       = ["drnicwilliams@gmail.com"]
  spec.description = %q{Create an Inception VM for Bosh}
  spec.summary     = %q{CLI, with chef recipes, for creating and preparing an Inception VM for deploying/developing a Bosh universe.}
  spec.homepage    = ""
  spec.license     = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "highline"
  spec.add_dependency "escape"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-kitchen", "~> 1.0.0.alpha"
  spec.add_development_dependency "kitchen-vagrant"
  spec.add_development_dependency "berkshelf"
end
