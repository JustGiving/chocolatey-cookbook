if node['platform_family'] == 'windows'
  default['chocolatey']['Uri']      = 'https://chocolatey.org/install.ps1'
  if (::File.exist?(::File.join(ENV['SYSTEMDRIVE'], 'ProgramData\\Chocolatey')))
  	default['chocolatey']['path']     = ::File.join(ENV['SYSTEMDRIVE'], 'ProgramData\\Chocolatey')
  else
  	default['chocolatey']['path']     = ::File.join(ENV['SYSTEMDRIVE'], 'Chocolatey')
  end
  default['chocolatey']['bin_path'] = ::File.join(node['chocolatey']['path'], 'bin')
  if (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'chocolatey.exe')))
    default['chocolatey']['bin_exe'] = 'chocolatey.exe'
  elsif (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'choco.exe')))
    default['chocolatey']['bin_exe'] = 'choco.exe'
  else
	default['chocolatey']['bin_exe'] = 'chocolatey.bat'
  end
  default['chocolatey']['bin_exe_path']=::File.join(node['chocolatey']['bin_path'], node['chocolatey']['bin_exe'])
  default['chocolatey']['upgrade']  = true
end
