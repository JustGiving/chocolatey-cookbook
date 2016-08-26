
include_recipe "chocolatey::default"

#Chef::Log.info ("WOOOOO")
chocolatey "sysinternals" do 
	action :install
end

#need to get chef client version or do we ?
#need to get chcoclatey version 
#if old version then 
#else 
#new version 
