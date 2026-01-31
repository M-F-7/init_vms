Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  # Synchronise le dossier local dans /vagrant
   config.vm.provider :libvirt do |libvirt|
      libvirt.driver = "qemu"
      libvirt.cpus = 4        # nombre de vCPU
      libvirt.memory = 4096   # RAM en Mo (ici 4 Go)
   end

  config.vm.synced_folder ".", "/vagrant"

  # config.vm.provision "shell", path: "init.sh", run: "always"
end
