# A String or Array of SSH public keys to populate the user"s .ssh/authorized_keys file.

default["disk"]["mounted"] = false
default["disk"]["device"] = "/dev/xvdf"
default["disk"]["fstype"] = "ext4"
default["user"]["username"] = `users | head -n 1`.strip
default["user"]["home"] = node.user.username == "root" ? "/root" : "/home/#{node["user"]["username"]}"
default["disk"]["dir"] = "#{node.user.home}/bosh-workspace"
default["git"]["name"] = "Nobody"
default["git"]["email"] = "nobody@in-the-house.com"

default["chruby"]["rubies"]["2.1.3"] = true
default["chruby"]["default"] = "2.1.3"

# Pass in credentials to be dropped into a ~/.fog file
# They will be automatically converted to symbolized keys
# to make fog happy
default["fog"] = {}
