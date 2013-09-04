execute "chmod g+w rvm" do
  command "chmod g+w /usr/local/rvm -R"
  action :run
end

