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
        action :deb
        notifies :restart, resources(:service => "diamond")
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
  variables(
    :diamond_handlers => node['diamond']['diamond_handlers'],
    :user => node['diamond']['diamond_user'],
    :group => node['diamond']['diamond_group'],
    :pidfile => node['diamond']['diamond_pidfile'],
    :collectors_path => node['diamond']['diamond_collectors_path'],
    :collectors_config_path => node['diamond']['collectors_config_path'],
    :reload_interval => node['diamond']['collectors_reload_interval'],
    :archive_handler => node['diamond']['archive_handler'],
    :graphite_handler => node['diamond']['graphite_handler'],
    :graphite_picklehandler => node['diamond']['graphite_picklehandler'],
    :mysqlhandler => node['diamond']['mysqlhandler'],
    :statsdhandler => node['diamond']['statsdhandler'],
    :tsdbhandler => node['diamond']['tsdbhandler'],
    :collectors => node['diamond']['collectors'],
  )
end

template "/etc/init/diamond.conf" do
  source "diamond.erb"
  mode 0755
  owner "root"
  group "root"
  variables(
    :path_to_diamond => node['diamond']['diamond_installation_path']
  )
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

service "diamond" do
  provider Chef::Provider::Service::Upstart
  action :start
end
