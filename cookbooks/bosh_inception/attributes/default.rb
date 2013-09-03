# A String or Array of SSH public keys to populate the user"s .ssh/authorized_keys file.

default["user"]["home"] = node.user.username == "root" ? "/root" : node["user"]["home"]
default["disk"]["mounted"] = false
default["disk"]["device"] = "/dev/xvdf"
default["disk"]["fstype"] = "btrfs"
default["disk"]["dir"] = "/var/vcap/store"
default["user"]["username"] = `users | head -n 1`.strip
default["git"]["name"] = "Nobody"
default["git"]["email"] = "nobody@in-the-house.com"
default["rvm"]["default_ruby"] = "ruby-1.9.3"
default["rvm"]["global_gems"] = [
  { "name"    => "bundler" },
  { "name"    => "rake" },
  { "name"    => "jazor" },
  { "name"    => "yaml_command" },
  { "name"    => "chef" },
  { "name"    => "rubygems-bundler",
    "action"  => "remove"
  }
]

# Pass in credentials to be dropped into a ~/.fog file
# They will be automatically converted to symbolized keys
# to make fog happy
default["fog"] = {}