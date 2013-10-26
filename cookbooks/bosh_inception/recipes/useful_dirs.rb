%w[microboshes microboshes/deployments deployments releases repos stemcells systems tmp bosh_cache].each do |dir|
  directory "#{node.disk.dir}/#{dir}" do
    owner node.user.username
    group node.user.username
    mode "0755"
    recursive true
    action :create
  end
end

link "#{node["user"]["home"]}/.bosh_cache" do
  to "#{node.disk.dir}/bosh_cache"
end
