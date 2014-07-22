if node['platform_family'] == 'windows'
  default['chocolatey']['Uri']      = 'https://chocolatey.org/install.ps1'
  if (::File.exist?(::File.join(ENV['SYSTEMDRIVE'], 'ProgramData\\Chocolatey')))
  	default['chocolatey']['path']     = ::File.join(ENV['SYSTEMDRIVE'], 'ProgramData\\Chocolatey')
  else
  	default['chocolatey']['path']     = ::File.join(ENV['SYSTEMDRIVE'], 'Chocolatey')
  end
  default['chocolatey']['bin_path'] = ::File.join(node['chocolatey']['path'], 'bin')
  default['chocolatey']['upgrade']  = true

  if (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'chocolatey.exe')))
    default['chocolatey']['chocolatey_exe'] = 'chocolatey.exe'
  elsif (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'choco.exe')))
    default['chocolatey']['chocolatey_exe'] = 'choco.exe'
  elsif (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'chocolatey.bat')))
    default['chocolatey']['chocolatey_exe'] = 'chocolatey.bat'
  elsif (::File.exist?(::File.join(node['chocolatey']['bin_path'], 'choco.bat')))
    default['chocolatey']['chocolatey_exe'] = 'choco.bat'
  end

  default['chocolatey']['exe_path'] = ::File.join(node['chocolatey']['bin_path'], node['chocolatey']['chocolatey_exe'])

end
