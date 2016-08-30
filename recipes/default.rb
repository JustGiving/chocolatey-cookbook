#
# Cookbook Name:: chocolatey
# recipe:: default
# Author:: Guilhem Lettron <guilhem.lettron@youscribe.com>
#
# Copyright 2012, Societe Publica.
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

return 'platform not supported' if node['platform_family'] != 'windows'
include_recipe 'windows'

#::Chef::Recipe.send(:include, Chef::Mixin::PowershellOut)
::Chef::Resource::RubyBlock.send(:include, Chef::Mixin::PowershellOut)


if (node['chocolatey']['jg_code_on'] == true)
  # new code feature switch 
  ChocolateyVersions.debug(node['chocolatey']['debug'])
  ChocolateyPackages.debug(node['chocolatey']['debug'])
  choco_version = ChocolateyVersions.get_choco_version()
  Chef::Log.info("chocolatey installed :#{ChocolateyVersions.chocolatey_installed?}")
  Chef::Log.info("chocolatey version :#{choco_version}")  
  ENV['chocolateyVersion'] = node['chocolatey']['pinned_version']
  ENV['chocolateyDownloadUrl'] = 'http://nuget.prod.justgiving.service/artifactory/int-chocolatey/chocolatey.0.10.0.nupkg'

  #replace this with execute command out to powershell , to remove the need to have powershell and therefor windows as a dependancy
  powershell_script 'install chocolatey' do
    code "iex ((new-object net.webclient).DownloadString('#{node['chocolatey']['Uri']}'))"
    convert_boolean_return true
    not_if { ChocolateyVersions.chocolatey_installed? }
  end

  ruby_block "reset ENV['ChocolateyInstall']" do
    block do
      cmd = powershell_out!("[System.Environment]::GetEnvironmentVariable('ChocolateyInstall', 'MACHINE')")
      ENV['ChocolateyInstall'] = cmd.stdout.chomp
      Chef::Log.info("ChocolateyInstall is '#{ENV['ChocolateyInstall']}'")
    end
  end

  if ((node['chocolatey']['force_to_specific_version'] == true) && (choco_version != '0.9.8.31'))
    if(choco_version != node['chocolatey']['pinned_version'])
      Chef::Log.info("CHOCO: Forced version install of chocolatey to version #{node['chocolatey']['pinned_version']}")
      powershell_script 'install chocolatey now' do
        code "iex ((new-object net.webclient).DownloadString('#{node['chocolatey']['Uri']}'))"
        convert_boolean_return true    
      end
      ruby_block "reset ENV['ChocolateyInstall']" do
        block do
          cmd = powershell_out!("[System.Environment]::GetEnvironmentVariable('ChocolateyInstall', 'MACHINE')")
          ENV['ChocolateyInstall'] = cmd.stdout.chomp
          Chef::Log.info("ChocolateyInstall is '#{ENV['ChocolateyInstall']}'")
        end
      end 
      file 'c:\windows\temp\choco_cached_version' do 
        action :delete
      end
    end 
  end

else
  #old code 

  Chef::Log.info("chocolatey installed :#{ChocolateyHelpers.chocolatey_installed?}")
  #replace this with execute command out to powershell , to remove the need to have powershell and therefor windows as a dependancy
  powershell_script 'install chocolatey' do
    code "iex ((new-object net.webclient).DownloadString('#{node['chocolatey']['Uri']}'))"
    convert_boolean_return true
    not_if { ChocolateyHelpers.chocolatey_installed? }
  end

  ruby_block "reset ENV['ChocolateyInstall']" do
    block do
      cmd = powershell_out!("[System.Environment]::GetEnvironmentVariable('ChocolateyInstall', 'MACHINE')")
      ENV['ChocolateyInstall'] = cmd.stdout.chomp
      Chef::Log.info("ChocolateyInstall is '#{ENV['ChocolateyInstall']}'")
    end
  end


end

# Issue #1: Cygwin "setup.log" size
file 'cygwin log' do
  path 'C:/cygwin/var/log/setup.log'
  action :delete
end


chocolatey 'chocolatey' do
  action :upgrade
  only_if { node['chocolatey']['upgrade'] }
end