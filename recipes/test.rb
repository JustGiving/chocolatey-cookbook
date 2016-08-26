
include_recipe "chocolatey::default"

Chef::Log.info ("WOOOOO")
chocolatey "notepadplusplus" do 
	action :install
end
Chef::Log.info ("WOOOOO1")
#need to get chef client version or do we ?
#need to get chcoclatey version 
#if old version then 
#else 
#new version 
