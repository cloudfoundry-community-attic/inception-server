%w[microboshes/deployments deployments releases repos stemcells inception tmp bosh_cache].each do |dir|
  directory "/var/vcap/#{dir}" do
    owner "vcap"
    group "vcap"
    mode "0755"
    recursive true
    action :create
  end
end