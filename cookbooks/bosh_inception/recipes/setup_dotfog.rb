if node.fog.empty?
  file "/home/#{node.user.username}/.fog" do
    owner "root"
    group "root"
    mode "0755"
    action :delete
  end
else
  ruby_block "create .fog file" do
    block do
      credentials = node.fog.inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
      fog_file = { default: credentials }
      dotfog = File.expand_path("/home/#{node.user.username}/.fog")
      File.open(dotfog, "w") do |f|
        f << fog_file.to_yaml
      end
    end
  end

  file "/home/#{node.user.username}/.fog" do
    owner node.user.username
    group node.user.username
    mode "0600"
    action :touch
  end
end
