source 'https://rubygems.org'

# Specify your gem's dependencies in bosh-inception.gemspec
gemspec

gem "settingslogic", github: "drnic/settingslogic", branch: "integration"

group :integration do
  gem 'test-kitchen', github: 'opscode/test-kitchen', branch: '1.0'
  gem 'kitchen-vagrant', github: 'opscode/kitchen-vagrant'
  gem 'kitchen-ec2', github: 'opscode/kitchen-ec2'
  gem 'knife-solo', github: 'matschaffer/knife-solo'
end