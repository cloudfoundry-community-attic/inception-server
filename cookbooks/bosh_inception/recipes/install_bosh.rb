rvm_gem "bosh_cli_plugin_micro" do
  ruby_string node.rvm.default_ruby
  version "~> 1.5.0.pre"
  source  "https://s3.amazonaws.com/bosh-jenkins-gems/"
  action  :install
end
