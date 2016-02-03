# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box_url = "http://box.dev.justgiving.service/win2012.box"
  config.vm.box = "win2012"
  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"  
  config.vm.guest = :windows  
  config.windows.halt_timeout = 15
  config.vm.communicator = "winrm"
  config.berkshelf.enabled = true
  config.vm.network :forwarded_port, guest: 3389, host: 23389
  config.vm.network :forwarded_port, guest: 5985, host: 25985

   config.vm.provider :virtualbox do |vb|     
     vb.gui = true    
     vb.customize ["modifyvm", :id, "--memory", "2048"]
   end

  config.vm.provision :chef_solo do |chef|
    #chef.data_bags_path = "data_bags"
    #chef.encrypted_data_bag_secret_key_path = 'encrypted_data_bag_secret'
    #chef.environment = 'dev'
    #chef.environments_path = 'environments'
    chef.log_level         = :debug
    chef.run_list = [     
      "recipe[chocolatey::test]"
    ]
  end
end