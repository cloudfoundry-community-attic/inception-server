cookbook_file "#{node.disk.dir}/microboshes/Gemfile" do
  source "Gemfile.micro"
  owner node.user.username
  group node.user.username
  mode "0644"
end

directory "#{node.disk.dir}/microboshes" do
  owner node.user.username
  group node.user.username
  mode "0755"
  recursive true
  action :create
end

bash "install bosh micro" do
  cwd "#{node.disk.dir}/microboshes"
  user node.user.username
  code "source /etc/profile.d/chruby.sh; bundle install"
  action :run
end

cookbook_file "#{node.disk.dir}/systems/Gemfile" do
  source "Gemfile.cf"
  owner node.user.username
  group node.user.username
  mode "0644"
end

bash "install bosh cf" do
  cwd "#{node.disk.dir}/systems"
  user node.user.username
  code "source /etc/profile.d/chruby.sh; bundle install"
  action :run
end
