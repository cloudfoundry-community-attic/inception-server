cookbook_file "/var/vcap/store/microboshes/Gemfile" do
  source "Gemfile.micro"
  owner "vcap"
  group "vcap"
  mode "0644"
end

execute "install bosh micro" do
  command "bundle install"
  cwd "/var/vcap/store/microboshes"
  action :run
end

cookbook_file "/var/vcap/store/systems/Gemfile" do
  source "Gemfile.cf"
  owner "vcap"
  group "vcap"
  mode "0644"
end

execute "install bosh cf" do
  command "bundle install"
  cwd "/var/vcap/store/systems"
  action :run
end
