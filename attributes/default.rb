if node['platform_family'] == 'windows'
  default['chocolatey']['Uri']      = 'https://chocolatey.org/install.ps1'
  if (::File.exist?(::File.join(ENV['SYSTEMDRIVE'], 'ProgramData\\Chocolatey')))
  	default['chocolatey']['path']     = ::File.join(ENV['SYSTEMDRIVE'], 'ProgramData\\Chocolatey')
  else
  	default['chocolatey']['path']     = ::File.join(ENV['SYSTEMDRIVE'], 'Chocolatey')
  end
  default['chocolatey']['bin_path'] = ::File.join(node['chocolatey']['path'], 'bin')
  default['chocolatey']['upgrade']  = true
end
