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
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[diamond]"
end

template "/etc/default/diamond" do
  source "diamond.default.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[diamond]"
end

# Install collectors
node['diamond']['add_collectors'].each do |c|
  include_recipe "diamond::#{c}"
end

service "diamond" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true
  action [:enable]
end
