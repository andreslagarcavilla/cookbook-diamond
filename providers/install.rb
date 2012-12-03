action :git do
  directory "create temp git path" do
    path "/mnt/git/#{new_resource.name}" 
    action :create
    recursive true
  end
  
  git "/mnt/git/#{new_resource.name}" do
    repository new_resource.git_repository_uri
    reference new_resource.git_reference
    action :checkout
    not_if { ::File.exists?("/usr/local/bin/diamond") || ::File.exists?("/mnt/git/#{new_resource.name}/setup.py") }
  end

  new_resource.required_python_packages.collect do |pkg, ver|
    python_pip pkg do
      version ver
      action :install
    end
  end

  execute "install diamond" do
    cwd "/mnt/git/#{new_resource.name}"
    command "python setup.py install"
    creates "/usr/local/bin/diamond"
  end

  directory "clean up temp git path" do
    path "/mnt/git/#{new_resource.name}"
    action :delete
    recursive true
  end
  new_resource.updated_by_last_action(true)
end

action :deb do
  directory "create temp git path" do
    path "/mnt/git/#{new_resource.name}" 
    action :create
    recursive true
  end
  
  git "/mnt/git/#{new_resource.name}" do
    repository new_resource.git_repository_uri
    reference new_resource.git_reference
    action :checkout
    not_if { ::File.exists?("/usr/bin/diamond") || ::File.exists?("/mnt/git/#{new_resource.name}/setup.py") }
  end

  new_resource.required_debian_packages.collect do |pkg|
    package pkg
  end
    
  execute "build diamond" do
    not_if "dpkg -l | grep diamond"
    cwd "/mnt/git/#{new_resource.name}"
    command "make builddeb"
  end

  package "diamond" do
    not_if "dpkg -l | grep diamond"
    source "/mnt/git/#{new_resource.name}/build/diamond_#{new_resource.diamond_version}_all.deb"
    provider Chef::Provider::Package::Dpkg
    version new_resource.diamond_version
    options "--force-confnew,confmiss"
    action :install
  end

  directory "clean up temp git path" do
    path "/mnt/git"
    action :delete
    recursive true
  end
  new_resource.updated_by_last_action(true)
end
