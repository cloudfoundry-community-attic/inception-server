source 'https://rubygems.org'

# Specify your gem's dependencies in bosh-inception.gemspec
gemspec

gem "settingslogic", github: "drnic/settingslogic", branch: "integration"

# gem 'knife-solo', github: 'matschaffer/knife-solo'
gem 'knife-solo', github: 'drnic/knife-solo', branch: 'continue_connecting'

group :integration do
  # gem 'test-kitchen', github: 'opscode/test-kitchen', branch: '1.0'
  gem 'kitchen-ec2'
end

group :vagrant do
  gem 'kitchen-vagrant', '~> 0.10.0'
end
