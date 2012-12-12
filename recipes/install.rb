# Diamond Install recipe

case node['diamond']['install_type']
  when :apt, :rpm
    execute "rm" do
      command "rm -f *"
      cwd "#{node['diamond']['diamond_configuration_path']}/collectors"
      action :run 
      only_if { ::File.exists?("#{node['diamond']['diamond_configuration_path']}/collectors") }
    end

    unless ::File.exists?('/usr/bin/diamond')
      package "diamond" do
        action :install
        version node['diamond']['version']
        notifies :start, resources(:service => "diamond")
      end
    end

  when :deb
    execute "rm" do
      command "rm -f *"
      cwd "#{node['diamond']['diamond_configuration_path']}/collectors"
      action :run 
      only_if { ::File.exists?("#{node['diamond']['diamond_configuration_path']}/collectors") }
    end

    unless ::File.exists?('/usr/bin/diamond') or node['diamond']['force_install']
      node['diamond']['required_debian_packages'].collect do |pkg|
        package pkg
      end

      directory "create_temp_git_path" do
        path node['diamond']['git_tmp']
        action :create
        recursive true
      end

      if node['diamond']['version'] != 'master' then
            node.override['diamond']['git_reference'] = "v#{node['diamond']['version']}"
      else
            node.override['diamond']['git_reference'] = node['diamond']['version']
      end

      git node['diamond']['git_path'] do
        repository node['diamond']['git_repository_uri']
        reference node['diamond']['git_reference']
        action :checkout
        not_if { ::File.exists?("#{node['diamond']['git_path']}/setup.py") }
      end

      execute "build diamond" do
        cwd node['diamond']['git_path']
        command "make builddeb"
      end

      ruby_block "log_diamond_version" do
        block do
          Chef::Log.info "Diamond version is #{node['diamond']['version']}."
          Chef::Log.info "Diamond package version is #{node['diamond']['package_version']}."
        end
      end

      package "diamond" do
        source "#{node['diamond']['git_path']}/build/diamond_#{node['diamond']['package_version']}_all.deb"
        provider Chef::Provider::Package::Dpkg
        version node['diamond']['package_version']
        options "--force-confnew,confmiss"
        action :install
	notifies :start, resources(:service => "diamond")
      end

      directory "clean up temp git path" do
        path node['diamond']['git_tmp']
        action :delete
        recursive true
      end
    end
end
