# install diamond and enable basic collectors

service "diamond" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true
  action :nothing
end

include_recipe "diamond::install"

template "/etc/diamond/diamond.conf" do
  action :create
  source "diamond.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "diamond")
end

template "/etc/init/diamond.conf" do
  source "diamond.erb"
  mode 0755
  owner "root"
  group "root"
  action :create_if_missing
end

cookbook_file "/etc/init.d/diamond" do
  source "diamond.init"
  mode 0755
  owner "root"
  group "root"
  action :create_if_missing
end

# Install collectors
node['diamond']['add_collectors'].each do |c|
  include_recipe "diamond::#{c}"
end

service "diamond" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true
  action [:enable, :start]
end
