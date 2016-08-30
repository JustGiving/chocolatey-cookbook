
include_recipe "chocolatey::default"


Chef::Log.info "Chef version: #{node['chef_packages']['chef']['version']}"

chocolatey "GG.Ops.Tools" do 
	action :install 
	version "2.0.49"
	source "http://nuget.prod.justgiving.service/artifactory/api/nuget/int-chocolatey"
end


chocolatey "sublimetext2" do 
	action :install
end

chocolatey "notepadplusplus" do 
	action :install
	version '6.9.2'
end

#prove downgrade

chocolatey "notepadplusplus" do 
	action :install
	version '6.8.3'
end





#need to get chef client version or do we ?
#need to get chcoclatey version 
#if old version then 
#else 
#new version 
