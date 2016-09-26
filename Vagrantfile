Vagrant.configure("2") do |config|
  config.vm.define "freebsd-r-dtrace"
  config.vm.guest = :freebsd
  config.vm.box = "freebsd/FreeBSD-10.3-STABLE"
  config.vm.hostname = "freebsd-r-dtrace"
  config.ssh.shell = "sh"
  config.vm.base_mac = "080027D14C66"

  config.vm.network "private_network", ip: "10.0.1.10"

  config.vm.synced_folder "./sandbox", "/vagrant", :nfs => true, id: "vagrant-root"

  config.vm.provider :virtualbox do |vb|
    vb.name = "freebsd-r-dtrace"
    vb.customize ["modifyvm", :id, "--memory", "1024"]
    vb.customize ["modifyvm", :id, "--cpus", "1"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
  end

  config.vm.provision "shell", path: "init.sh", privileged: true
end
