user_account "vcap" do
  comment "bosh inception"
  manage_home true
  create_group true
end

user_account "vcap" do
  ssh_keys node.user.authorized_keys
  action :modify
end

sudo "vcap" do
  user      "%vcap"
  runas     "vcap"
end

