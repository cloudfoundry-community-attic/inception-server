# A String or Array of SSH public keys to populate the user"s .ssh/authorized_keys file.
default["user"]["authorized_keys"] = []
default["git"]["name"] = "Nobody"
default["git"]["email"] = "nobody@in-the-house.com"
default["rvm"]["default_ruby"] = "ruby-1.9.3"
default["rvm"]["global_gems"] = [
  { "name"    => "bundler" },
  { "name"    => "rake" },
  { "name"    => "jazor" },
  { "name"    => "yaml_command" },
  { "name"    => "rubygems-bundler",
    "action"  => "remove"
  }
]
