class Php7dev
  def Php7dev.configure(config, settings)
    # Configure The Box
    config.vm.box = "rasmus/php7dev"
    config.vm.hostname = settings["vm_name"]
    if settings['networking'][0]['public']
      config.vm.network "public_network", type: "dhcp"
    end

    # Configure A Few VirtualBox Settings
    config.vm.provider "virtualbox" do |vb|
      vb.name = settings["vm_name"]
      vb.customize ["modifyvm", :id, "--description", settings["vm_description"] ||= ""]
      vb.customize ["modifyvm", :id, "--memory", settings["memory"] ||= "2048"]
      vb.customize ["modifyvm", :id, "--cpus", settings["cpus"] ||= "1"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--ostype", "Debian_64"]
      vb.customize ["modifyvm", :id, "--audio", "none", "--usb", "off", "--usbehci", "off"]
    end


    # Configure Port Forwarding To The Box
    config.vm.network "forwarded_port", guest: 80, host: 8000
#    config.vm.network "forwarded_port", guest: 443, host: 44300
#    config.vm.network "forwarded_port", guest: 3306, host: 33060

    # Add Custom Ports From Configuration
    if settings.has_key?("ports")
      settings["ports"].each do |port|
        config.vm.network "forwarded_port", 
            guest: port["guest"], 
            host: port["host"], 
            protocol: port["protocol"] ||= "tcp"
      end
    end

    # Register All Of The Configured Local Folders
    if settings['local_folders'].kind_of?(Array)
      settings["local_folders"].each do |folder|
        config.vm.provision "file", 
            source: folder["map"], 
            destination: folder["to"]
      end
    end

    # Register All Of The Configured Shared Folders
    if settings['synced_folders'].kind_of?(Array)
      settings["synced_folders"].each do |folder|
        config.vm.synced_folder folder["map"], 
            folder["to"], 
            type: folder["type"] ||= nil,
            owner: folder["owner"] ||= "vagrant",
            group: folder["group"] ||= "vagrant",
            mount_options: ["dmode=775,fmode=664"],
            create: true
      end
    end

    # Update Composer On Every Provision
    config.vm.provision "shell" do |s|
      s.inline = "/usr/local/bin/composer self-update --no-progress"
    end
  end
end

