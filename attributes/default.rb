if node['platform_family'] == 'windows'
  default['chocolatey']['Uri']         = 'https://chocolatey.org/install.ps1'
  default['chocolatey']['upgrade']     = false  # OP set this to false by default 
  default['chocolatey']['debug']	   = true
  default['chocolatey']['jg_code_on']  = true
end
