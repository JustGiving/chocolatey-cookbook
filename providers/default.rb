#
# Provider:: chocolatey
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
# Copyright 20012, Societe Publica.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

use_inline_resources

# Support whyrun
def whyrun_supported?
  true
end

def load_current_resource  
  @current_resource = Chef::Resource::Chocolatey.new(@new_resource.name)
  @chocolatey_start = Time.now  
  @current_resource.name(@new_resource.name)
  @current_resource.version(@new_resource.version)
  @current_resource.source(@new_resource.source)
  @current_resource.args(@new_resource.args)
  @current_resource.options(@new_resource.options)
  @current_resource.package(@new_resource.package)
  if(jg_new_code_on? == true)   
    @chocolatey_installed = ChocolateyVersions.chocolatey_installed?
    @chocolatey_version = ChocolateyVersions.get_choco_version()
    ChocolateyVersions.debug(node['chocolatey']['debug'])
    ChocolateyPackages.debug(node['chocolatey']['debug'])
  end
  @current_resource.exists = true if package_exists?(@current_resource.package, @current_resource.version)
  #@current_resource.upgradeable = true if upgradeable?(@current_resource.package)
  #@current_resource.installed = true if package_installed?(@current_resource.package)
end

action :install do
  Chef::Log.info("chocolatey installed :#{ChocolateyVersions.chocolatey_installed?}")
  Chef::Log.info("chocolatey version :#{ChocolateyVersions.get_choco_version()}")
  if @current_resource.exists
    Chef::Log.info "#{ @current_resource.package } already installed - nothing to do."
  elsif @current_resource.version
    install_version(@current_resource.package, @current_resource.version)
  else
    install(@current_resource.package)
  end
  Chef::Log.info "Chocolatey install execution time: #{time_diff()} s"
end

action :upgrade do
  if upgradeable?(@current_resource.package)
    upgrade(@current_resource.package)
  else
    Chef::Log.info("Package #{@current_resource} already to latest version")    
  end
   Chef::Log.info "Chocolatey upgrade execution time: #{time_diff()} s"
end

action :remove do
  if @current_resource.exists
    converge_by("uninstall package #{ @current_resource.package }") do
      if (jg_code_on_and_new_version?)      
        jg_uninstall(@current_resource.package) 
      else
        execute "uninstall package #{@current_resource.package}" do
          command "#{::ChocolateyHelpers.chocolatey_executable} uninstall  #{@new_resource.package} #{cmd_args}"
        end
      end
    end
  else
    Chef::Log.info "#{ @new_resource } not installed - nothing to do."
  end
   Chef::Log.info "Chocolatey remove execution time: #{time_diff()} s"
end

def cmd_args
  output = ''
  output += " -source #{@current_resource.source}" if @current_resource.source
  output += " -ia '#{@current_resource.args}'" unless @current_resource.args.to_s.empty?
  @current_resource.options.each do |k, v|
    output += " -#{k}"
    output += " #{v}" if v
  end
  output
end

def package_with_name_in_lib_folder?(name,version)
  found = false
  find = name 
  if(version)
    find = "#{name}.#{version}"
  end 
  directory = ChocolateyHelpers.chocolatey_lib_folder
  x = ::Dir.entries(directory).select { |file| ::File.directory? ::File.join(directory, file)}
  x.each do |d|
    if(d.include?(find))
      found = true
      break
    end
  end
  Chef::Log.debug "package_with_name_in_lib_folder found: #{found}"
  return found
end

def time_diff()
   (Time.now - @chocolatey_start) 
end

def package_installed?(name)
  cmd = Mixlib::ShellOut.new("#{::ChocolateyHelpers.chocolatey_executable} version #{name} -localonly #{cmd_args}")
  cmd.run_command
  cmd.exitstatus == 0
end

def package_exists?(name, version)
  if (jg_code_on_and_new_version?)      
      return jg_package_exists?(name, version) 
  end
  #old code 
  if package_with_name_in_lib_folder?(name,version) 
    return true 
  end
  Chef::Log.debug "not found in lib folder, moving on"
  return false unless package_installed?(name)
  return true unless version
  cmd = Mixlib::ShellOut.new("#{::ChocolateyHelpers.chocolatey_executable} version #{name} -localonly #{cmd_args}")
  cmd.run_command
  software = cmd.stdout.split("\r\n").each_with_object({}) do |s, h|
    v, k = s.split
    h[String(v).strip] = String(k).strip
    h
  end
  software[name] == version
  
end

def upgradeable?(name)
  #TO DO JG BIT
  return false unless @current_resource.exists
  unless package_installed?(name)
    Chef::Log.debug("Package isn't installed... we can upgrade it!")
    return true
  end
  Chef::Log.debug("Checking to see if this chocolatey package is installed/upgradable: '#{name}'")
  cmd = Mixlib::ShellOut.new("#{::ChocolateyHelpers.chocolatey_executable} version #{name} #{cmd_args}")
  cmd.run_command
  !cmd.stdout.include?('Latest version installed')
end

def install(name)
  if (jg_code_on_and_new_version?)      
     jg_install(name) 
  else
    execute "install package #{name}" do
      command "#{::ChocolateyHelpers.chocolatey_executable} install #{name} #{cmd_args}"
    end
  end
end

def upgrade(name)
   if (jg_code_on_and_new_version?)      
     jg_install(name) 
  else
  execute "updating #{name} to latest" do
    command "#{::ChocolateyHelpers.chocolatey_executable} update #{name} #{cmd_args}"
  end 
  end 
end

def install_version(name, version)
  if (jg_code_on_and_new_version?)      
     jg_install_version(name,version) 
  else
    execute "install package #{name} version #{version}" do
      command "#{::ChocolateyHelpers.chocolatey_executable} install #{name} -version #{version} #{cmd_args}"
    end
  end
end

###

def jg_uninstall(name)
  execute "uninstall package #{@current_resource.package}" do
    command "#{::ChocolateyHelpers.chocolatey_executable} uninstall  #{name} #{jg_cmd_args}"
  end  
end


def jg_upgrade(name)
  execute "updating #{name} to latest" do
    command "#{::ChocolateyHelpers.chocolatey_executable} update #{name} -y #{jg_cmd_args}"
  end  
end

def jg_install(name)
  execute "install package #{name}" do
      command "#{::ChocolateyHelpers.chocolatey_executable} install #{name} -y #{jg_cmd_args}"
  end
end

def jg_install_version(name, version)
  execute "install package #{name} version #{version}" do
      command "#{::ChocolateyHelpers.chocolatey_executable} install #{name} -y -f --version #{version} #{jg_cmd_args}"
  end
end

def jg_new_code_on?
  return node['chocolatey']['jg_code_on'] == true
end  

def log(msg)
  Chef::Log.info("CHOCO: #{msg}")
end

def jg_package_exists?(name, version)
  return jg_package_installed?(name,version)
end

def jg_package_installed?(name,version)
  log("jg_package_installed? [#{name}] [#{version}]")
  cmd = Mixlib::ShellOut.new("#{::ChocolateyVersions.chocolatey_executable} list --local-only")
  cmd.run_command  
  data = cmd.stdout
  success = (cmd.exitstatus == 0)
  if(success)
    result = ::ChocolateyPackages.is_package_listed?(name,version,data)
    log("is package listed [#{result}]")
    return result
  else
    raise "Failed to execute choco list --localonly"
  end
end

def jg_code_on_and_new_version?
  if (jg_new_code_on?)   
    if(@chocolatey_version != '0.9.8.31')    # maybe swap with array.include?  
      log("JG code is on and we are on a newer version")
      return true 
    end
  end
  return false
end

def jg_cmd_args
  output = ''
  output += " --source #{@current_resource.source}" if @current_resource.source
  output += " --ia '#{@current_resource.args}'" unless @current_resource.args.to_s.empty?
  @current_resource.options.each do |k, v|
    output += " -#{k}"
    output += " #{v}" if v
  end
  output
end