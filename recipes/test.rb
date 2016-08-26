
include_recipe "chocolatey::default"


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
