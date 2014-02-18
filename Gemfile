source 'https://rubygems.org'

# Specify your gem's dependencies in inception.gemspec
gemspec

cyoi = File.expand_path("../../cyoi", __FILE__)
if File.directory?(cyoi)
  gem "cyoi", path: cyoi
end

# gem 'knife-solo', github: 'matschaffer/knife-solo'
# gem 'knife-solo', github: 'drnic/knife-solo', branch: 'continue_connecting'

gem "unf"

group :integration do
  gem 'kitchen-ec2'
end

group :vagrant do
  gem 'kitchen-vagrant'
end

group :development do
  gem "awesome_print"
  gem "rb-fsevent", "~> 0.9.1"
  gem "guard-rspec"
end

