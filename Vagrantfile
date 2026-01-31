Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  # Synchronise le dossier local dans /vagrant
  config.vm.synced_folder ".", "/vagrant"

  config.vm.provision "shell", path: "init.sh", run: "always"
end
