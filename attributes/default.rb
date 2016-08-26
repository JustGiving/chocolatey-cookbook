if node['platform_family'] == 'windows'
  default['chocolatey']['Uri']         = 'https://chocolatey.org/install.ps1'
  default['chocolatey']['upgrade']     = false
  default['chocolatey']['debug']	   = false
  default['chocolatey']['jg_code_on']  = true
end
