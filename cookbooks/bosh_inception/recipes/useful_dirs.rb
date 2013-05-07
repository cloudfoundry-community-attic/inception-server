%w[microboshes microboshes/deployments deployments releases repos stemcells systems tmp bosh_cache].each do |dir|
  directory "/var/vcap/store/#{dir}" do
    owner node.user.username
    group node.user.username
    mode "0755"
    recursive true
    action :create
  end
end

link "/home/vcap/.bosh_cache" do
  to "/var/vcap/store/bosh_cache"
end