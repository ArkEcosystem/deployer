Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "forwarded_port", id: "P2P API", guest: 4102, host: 14102, guest_ip: "192.168.33.10"
  config.vm.network "forwarded_port", id: "Public API", guest: 4103, host: 14103, guest_ip: "192.168.33.10"
  config.vm.network "forwarded_port", id: "Explorer", guest: 4200, host: 14200, guest_ip: "192.168.33.10"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
  end
  config.vm.provision "shell", path: "vagrant/setup.sh", privileged: false
end
