user_account "vcap" do
  comment "bosh inception"
  manage_home true
  create_group true
end

sudo "vcap" do
  user      "%vcap"
  runas     "vcap"
end
