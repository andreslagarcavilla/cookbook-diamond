# install diamond and enable basic collectors

service "diamond" do
  action [ :nothing ]
end

case node[:platform]
  when "debian", "ubuntu"
    package "python-pysnmp4" do
      action :install
    end

    package "diamond" do
      action :install
      version node['diamond']['version']
      notifies :restart, resources(:service => "diamond")
    end

  when "centos", "redhat", "fedora", "amazon", "scientific"
    package "diamond" do
      action :install
      version node['diamond']['version']
      notifies :restart, resources(:service => "diamond")
    end
end

service "diamond" do
  action [ :enable ]
end

template "#{new_resource.diamond_configuration_path}/diamond.conf" do
  source new_resource.diamond_configuration_source
  mode 0644
  owner "root"
  group "root"
  variables({
            :diamond_handlers => new_resource.diamond_handlers,
            :user => new_resource.diamond_user,
            :group => new_resource.diamond_group,
            :pidfile => new_resource.diamond_pidfile,
            :collectors_path => new_resource.diamond_collectors_path,
            :collectors_config_path => new_resource.collectors_config_path,
            :reload_interval => new_resource.collectors_reload_interval,
            :archive_handler => new_resource.archive_handler,
            :graphite_handler => new_resource.graphite_handler,
            :graphite_picklehandler => new_resource.graphite_picklehandler,
            :statsdhandler => new_resource.statsdhandler,
            :mysqlhandler => new_resource.mysqlhandler,
            :tsdbhandler => new_resource.tsdbhandler,
            :collectors => new_resource.collectors
            })
  notifies :restart, resources(:service => "diamond")
end

#install basic collector configs
include_recipe 'diamond::diskusage'
include_recipe 'diamond::diskspace'
include_recipe 'diamond::vmstat'
include_recipe 'diamond::memory'
include_recipe 'diamond::network'
include_recipe 'diamond::tcp'
include_recipe 'diamond::loadavg'
include_recipe 'diamond::cpu'

