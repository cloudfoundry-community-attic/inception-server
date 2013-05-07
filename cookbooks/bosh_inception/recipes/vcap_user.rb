user_account node.user.username do
  comment "bosh inception"
  manage_home true
  create_group true
end

user_account node.user.username do
  ssh_keys node.user.authorized_keys
  action :modify
end

sudo node.user.username do
  user      "%vcap"
  runas     node.user.username
end

