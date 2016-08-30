if node['platform_family'] == 'windows'
  default['chocolatey']['Uri']         = 'https://chocolatey.org/install.ps1'
  default['chocolatey']['upgrade']     = false  # OP set this to false by default 
  default['chocolatey']['debug']	   = true
  default['chocolatey']['jg_code_on']  = true
  default['chocolatey']['force_to_specific_version'] = true 
  default['chocolatey']['pinned_version'] = '0.10.0'
  default['chocolatey']['source'] = 'http://nuget.prod.justgiving.service/artifactory/api/nuget/int-chocolatey'
end
