case node['platform']
  when "ubuntu", "debian"
    default['diamond']['version'] = '3.0.2'
    default['diamond']['package_version'] = '3.0.2'
    default['diamond']['install_type'] = :deb
  else
    default['diamond']['version'] = '3.2'
    default['diamond']['package_version'] = '3.0.2-0'
    default['diamond']['install_type'] = :rpm
end

default['diamond']['cookbook'] = "diamond"
default['diamond']['diamond_configuration_path'] = "/etc/diamond"
default['diamond']['diamond_installation_path'] = "/usr"
default['diamond']['diamond_configuration_source'] = "diamond.conf.erb"
default['diamond']['diamond_handlers'] = "diamond.handler.archive.ArchiveHandler, diamond.handler.graphitepickle.GraphitePickleHandler"
default['diamond']['diamond_user'] = String.new
default['diamond']['diamond_group'] = String.new
default['diamond']['diamond_pidfile'] = "/var/run/diamond/diamond.pid"
default['diamond']['collectors_config_path'] = "/etc/diamond/collectors/"
default['diamond']['handlers_config_path'] = "/etc/diamond/handlers/"
default['diamond']['diamond_collectors_path'] = "#{node['diamond']['diamond_installation_path']}/share/diamond/collectors/"
default['diamond']['collectors_reload_interval'] = 3600
default['diamond']['archive_handler'] = { "log_file" => "/var/log/diamond/diamond.log", "days" => 7 }
default['diamond']['graphite_handler'] = { "host" => "127.0.0.1", "port" => 2003, "batch" => 256, "timeout" => 15 }
default['diamond']['graphite_picklehandler'] = { "host" => "127.0.0.1", "port" => 2004, "batch" => 256, "timeout" => 15 }
default['diamond']['statsdhandler'] = { "host" => "127.0.0.1", "port" => 8125 }
default['diamond']['tsdbhandler'] = { "host" => "127.0.0.1", "port" => 4242, "timeout" => 15 }
default['diamond']['mysqlhandler'] = { "host" => "127.0.0.1", "port" => 3306, "username" => nil, "password" => nil, "database" => "diamond", "table" => "metrics", "col_time" => "timestamp", "col_metric" => "metric", "col_value" => "value" }
default['diamond']['collectors'] = { "hostname_method" => "smart", "hostname" => nil, "path_prefix" => nil, "path_suffix" => nil, "interval" => 300 }
default['diamond']['force_install'] = false
default['diamond']['add_collectors'] = ['cpu', 'diskspace', 'diskusage', 'loadavg', 'memory', 'sockstat', 'vmstat']
