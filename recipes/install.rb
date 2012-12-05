# Diamond Install recipe

case node['diamond']['install_type']
  when :apt, :rpm
    unless ::File.exists?('/usr/bin/diamond')
      package "diamond" do
        action :install
        version node[:diamond][:version]
      end
    end

  when :deb
    unless ::File.exists?('/usr/bin/diamond')
      node[:diamond][:required_debian_packages].collect do |pkg|
        package pkg
      end

      directory "create_temp_git_path" do
        path node[:diamond][:git_tmp]
        action :create
        recursive true
      end

      git node[:diamond][:git_path] do
        repository node['diamond']['git_repository_uri']
        reference node['diamond']['git_reference']
        action :checkout
        not_if { ::File.exists?("/mnt/git/#{new_resource.name}/setup.py") }
      end

      ruby_block "get_diamond_version" do
        block do
          cmd = Mixlib::ShellOut.new("cd #{node[:diamond][:git_path]} && ./version.sh").run_command
          node.set[:diamond][:version] = cmd.stdout.gsub("\n",'')
          Chef::Log.info "Diamond version is #{node[:diamond][:version]}."
        end
      end

      execute "build diamond" do
        cwd node[:diamond][:git_path]
        command "make builddeb"
      end

      package "diamond" do
        source "#{node[:diamond][:git_path]}/build/diamond_#{node['diamond']['version']}_all.deb"
        provider Chef::Provider::Package::Dpkg
        version node['diamond']['version']
        options "--force-confnew,confmiss"
        action :install
      end

      directory "clean up temp git path" do
        path node[:diamond][:git_tmp]
        action :delete
        recursive true
      end
    end

  when :git
    unless ::File.exists?('/usr/bin/diamond')
      node[:diamond][:required_python_packages].collect do |pkg, ver|
        python_pip pkg do
          version ver
          action :install
        end
      end

      directory "create_temp_git_path" do
        path node[:diamond][:git_tmp]
        action :create
        recursive true
      end

      git node[:diamond][:git_path] do
        repository node['diamond']['git_repository_uri']
        reference node['diamond']['git_reference']
        action :checkout
        not_if { ::File.exists?("/mnt/git/#{new_resource.name}/setup.py") }
      end

      execute "install diamond" do
        cwd node[:diamond][:git_path]
        command "python setup.py install"
        creates "/usr/local/bin/diamond"
      end

      directory "clean up temp git path" do
        path node[:diamond][:git_tmp]
        action :delete
        recursive true
      end
    end
end
