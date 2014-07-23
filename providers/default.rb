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
  @current_resource.name(@new_resource.name)
  @current_resource.version(@new_resource.version)
  @current_resource.source(@new_resource.source)
  @current_resource.args(@new_resource.args)
  @current_resource.params(@new_resource.params)
  @current_resource.package(@new_resource.package)
  @current_resource.upgradeable=false

  #installed=package_installed?(@current_resource.package)
  #@current_resource.installed = true if installed

  #if (installed)
  #  v_info = version_info(@current_resource.package)
  #  @current_resource.version_info(v_info)
  #  version_number=extract_version_number(v_info)
  #  if (version_number != nil)
  #    @current_resource.installed_version(version_number)
  #  end
  #  @current_resource.upgradeable = true if v_info.include?("A more recent version is available")
  #end

  @current_resource.exists = true if exists?(@current_resource.package, @current_resource.version)
  @current_resource
end

action :install do
  if @current_resource.exists
    Chef::Log.info "#{ @current_resource.package } already installed - nothing to do."
  elsif @current_resource.version
    install_version(@current_resource.package, @current_resource.version)
  else
    install(@current_resource.package)
  end
end

action :upgrade do
  if upgradeable?(@current_resource.package)
    upgrade(@current_resource.package)
  else
    Chef::Log.info("Package #{@current_resource} already to latest version")
  end
end

action :remove do
  if @current_resource.exists
    converge_by("uninstall package #{ @current_resource.package }") do
      execute "uninstall package #{@current_resource.package}" do
        command "#{chocolatey_exe} uninstall  #{@new_resource.package} #{cmd_args}"
      end
    end
  else
    Chef::Log.info "#{ @new_resource } not installed - nothing to do."
  end
end

def chocolatey_exe
  if (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'chocolatey.exe')))
    choco_exe = 'chocolatey.exe'
  elsif (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'choco.exe')))
    choco_exe = 'choco.exe'
  elsif (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'chocolatey.bat')))
    choco_exe = 'chocolatey.bat'
  elsif (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'choco.bat')))
    choco_exe = 'choco.bat'
  else
    fail "Couldn't locate a chocolatey executable"
  end
  return ::File.join(node['chocolatey']['bin_path'], choco_exe)
end

def cmd_args
  output = ''
  output += " -source #{@current_resource.source}" if @current_resource.source
  output += " -ia '#{@current_resource.args}'" unless @current_resource.args.to_s.empty?
  output += " -params '#{@current_resource.params}'" unless @current_resource.params.to_s.empty?
  output
end

def extract_version_number(version_output)
  version_regex='\d+(.\d+)?(.\d+)?(.\d+)?'
  version_output.split("\r\n").reduce({}) do |h, s|
    if String(s).start_with?("found ")
      if s.match(version_regex)
        return String(s.match(version_regex))
      end
    end
  end
  return nil
end

def extract_latest_version_number(version_output)
  version_regex='\d+(.\d+)?(.\d+)?(.\d+)?'
  version_output.split("\r\n").reduce({}) do |h, s|
    if String(s).start_with?("latest ")
      if s.match(version_regex)
        return String(s.match(version_regex))
      end
    end
  end
  return nil
end

def version_greater_than_or_equal(input1,input2)
  input1_parts=input1.split('.').reverse
  input2_parts=input2.split('.').reverse
  
  num1=input1_parts.pop
  num2=input2_parts.pop

  while num1 != nil and num2 != nil do
    if (String(num1).to_i > String(num2).to_i)
      return true
    elsif(String(num1).to_i < String(num2).to_i)
      return false
    end

    num1=input1_parts.pop
    num2=input2_parts.pop
  end

  return true # equal
end

def local_info(name)
  cmd_statement="#{chocolatey_exe} version #{name} -localonly #{cmd_args}"
  #Chef::Log.debug cmd_statement
  cmd = Mixlib::ShellOut.new(cmd_statement)
  cmd.run_command
  return cmd.stdout
end

def version_info(name)
  cmd_statement="#{chocolatey_exe} version #{name} #{cmd_args}"
  #Chef::Log.debug cmd_statement
  cmd = Mixlib::ShellOut.new(cmd_statement)
  cmd.run_command
  return cmd.stdout
end

def installed_version(name)
  return extract_version_number(@current_resource.version_info)
end

def package_installed?(name)
  Chef::Log.debug("Package '#{name} installed?")
  if (name == "chocolatey")
    Chef::Log.debug("c:/chocolatey exists? #{::File.exist?("c:/chocolatey")}")
    return ::File.exist?("c:/chocolatey")
  end
  Chef::Log.debug("Looking for #{node['chocolatey']['path']}/lib/#{name}*")
  return !Dir.glob("#{node['chocolatey']['path']}/lib/#{name}*").empty?
end
def package_version_installed?(name,version)
  if (name == "chocolatey")
    v_info = version_info("chocolatey")
    installed_version=extract_version_number(v_info)
    return true if (installed_version == version)
  end
  Chef::Log.debug("Looking for #{node['chocolatey']['path']}/lib/#{name}.#{version}")
  return ::File.exist?("#{node['chocolatey']['path']}/lib/#{name}.#{version}")
end

def exists?(name, version)
  if (version != nil)
    return true if package_version_installed?(name,version)
  else
    return true if package_installed?(name)
  end
end

def upgradeable?(name)
  if @current_resource.exists
    Chef::Log.debug("Checking to see if this chocolatey package is installed/upgradable: '#{name}'")
    v_info = version_info(@current_resource.package)
    return true if v_info.include?("A more recent version is available")
  else
    Chef::Log.debug("Package isn't installed... we can upgrade it!")
    return true
  end
end

def install(name)
  command_statement = "#{chocolatey_exe} install #{name} #{cmd_args}"
  Chef::Log.debug command_statement
  execute "install package #{name}" do
    command command_statement
    not_if {package_installed?(name)}
  end
end

def upgrade(name)
  v_info=version_info(name)
  if v_info.include?('A more recent version is available')
    existing_version="#{extract_version_number(v_info)}"
    new_version="#{extract_latest_version_number(v_info)}"
    backup_folder_name="backup-Chocolatey-#{existing_version}"
    backup_folder_path="#{::File.join(ENV['SYSTEMDRIVE'], backup_folder_name)}"
    Chef::Log.debug "This version of #{name} will be upgraded #{existing_version} -> #{new_version}. Will backup current version to #{backup_folder_path}"

    if ::File.exists?(backup_folder_path)
      ::File.delete backup_folder_path
    end

    ::File.rename node['chocolatey']['path'], backup_folder_path

    cmd = Mixlib::ShellOut.new("@powershell -NoProfile -ExecutionPolicy unrestricted -Command \"iex ((new-object net.webclient).DownloadString('#{node['chocolatey']['Uri']}'))\" && SET PATH=%PATH%;%systemdrive%\\chocolatey\\bin")
    cmd.run_command

    if ::File.exists?(::File.join(backup_folder_path,"lib"))
      if !::File.exists?(::File.join(node['chocolatey']['path'],"lib"))
        Dir.mkdir ::File.join(node['chocolatey']['path'],"lib")
      end
      ::FileUtils.copy_entry ::File.join(backup_folder_path,"lib"), ::File.join(node['chocolatey']['path'],"lib")
    end

    if ::File.exists?(::File.join(backup_folder_path,"lib-bad"))
      if !::File.exists?(::File.join(node['chocolatey']['path'],"lib-bad"))
        Dir.mkdir ::File.join(node['chocolatey']['path'],"lib-bad")
      end
      ::FileUtils.copy_entry ::File.join(backup_folder_path,"lib-bad"), ::File.join(node['chocolatey']['path'],"lib-bad")
    end

    new_version=extract_version_number(version_info(name))
    Chef::Log.debug "updated version: #{new_version}"
  end
end

def install_version(name, version)
  execute "install package #{name} to version #{version}" do
    command_statement "#{chocolatey_exe} install #{name} -version #{version} #{cmd_args}"
    Chef::Log.debug command_statement
    command command_statement
  end
end
