# install diamond and enable basic collectors

include_recipe "diamond::install"

service "diamond" do
  provider Chef::Provider::Service::Upstart
  action [:enable]
end

template ::File.join(node['diamond']['diamond_configuration_path'], "diamond.conf") do
  action :create
  source "diamond.conf.erb"
  mode 00644
  owner "root"
  group "root"
  notifies :restart, "service[diamond]"
end

if node['diamond']['install_type'] == :deb
  template "/etc/default/diamond" do
    source "diamond.default.erb"
    mode 00644
    owner "root"
    group "root"
    notifies :restart, "service[diamond]"
  end
end

# Install collectors
node['diamond']['add_collectors'].each do |c|
  include_recipe "diamond::#{c}"
end

# Make sure the pid dir is there.
# /run is mounted tmpfs on ubuntu
# so we can lose it on a reboot.
if not ::File.exists?("/run/diamond")
  directory "/run/diamond" do
    owner "diamond"
    group "root"
    mode 00755
    action :create
  end
end
