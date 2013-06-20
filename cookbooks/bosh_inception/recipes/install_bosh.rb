cookbook_file "/var/vcap/store/microboshes/Gemfile" do
  source "Gemfile.micro"
  owner node.user.username
  group node.user.username
  mode "0644"
end

directory "/var/vcap/store/microboshes" do
  owner node.user.username
  group node.user.username
  mode "0755"
  recursive true
  action :create
end

bash "install bosh micro" do
  cwd "/var/vcap/store/microboshes"
  user node.user.username
  code "source /etc/profile.d/chruby.sh; bundle install"
  action :run
end

cookbook_file "/var/vcap/store/systems/Gemfile" do
  source "Gemfile.cf"
  owner node.user.username
  group node.user.username
  mode "0644"
end

bash "install bosh cf" do
  cwd "/var/vcap/store/systems"
  user node.user.username
  code "source /etc/profile.d/chruby.sh; bundle install"
  action :run
end
