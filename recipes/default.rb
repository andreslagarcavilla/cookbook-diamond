# install diamond and enable basic collectors

service "diamond" do
  action [ :nothing ]
end

case node[:platform]
  when "debian", "ubuntu"
    package "python-pysnmp4" do
      action :install
    end

    diamond_install node['hostname'] do
        action :git
    end

  when "centos", "redhat", "fedora", "amazon", "scientific"
    package "diamond" do
      action :install
      version node['diamond']['version']
      notifies :restart, resources(:service => "diamond")
    end
end

template "/etc/diamond/diamond.conf" do
  source "diamond.conf.erb"
  mode 0644
  owner "root"
  group "root"
  notifies :restart, resources(:service => "diamond")
end

cookbook_file "/etc/init/diamond.conf" do
  source "diamond.conf"
  mode 0755
  owner "root"
  group "root"
end

cookbook_file "/etc/init.d/diamond" do
  source "diamond.init"
  mode 0755
  owner "root"
  group "root"
end

#install basic collector configs
include_recipe 'diamond::diskusage'
#include_recipe 'diamond::diskspace'
include_recipe 'diamond::vmstat'
include_recipe 'diamond::memory'
#include_recipe 'diamond::network'
#include_recipe 'diamond::tcp'
include_recipe 'diamond::loadavg'
include_recipe 'diamond::cpu'

service "diamond" do
  action [ :enable ]
end

#service "diamond" do
#  provider Chef::Provider::Service::Upstart
#  action :start
#end
