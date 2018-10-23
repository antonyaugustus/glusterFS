# -*- mode: ruby -*-
# vi: set ft=ruby :

#variables
tag="vm"
nodeCount=3
privateNetworkIp="192.168.40.40"       # Starting IP range for the private network between nodes

privateSubnet = privateNetworkIp.split(".")[0...3].join(".")
privateStartingIp = privateNetworkIp.split(".")[3].to_i

# Create hosts data
hosts = ""
nodeCount.times do |i|
  id = i+1
  hosts << "#{privateSubnet}.#{privateStartingIp + id} #{tag}#{id}\n"
end

$conf_env = <<SCRIPT
#!/bin/bash
cat > /etc/hosts <<EOF
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

#{hosts}
EOF

yum install -y centos-release-gluster
yum install -y glusterfs-server
systemctl enable glusterd && systemctl start glusterd

mkdir -p /home/vagrant/bricks/gv0

SCRIPT

# This defines the version of vagrant
Vagrant.configure(2) do |config|
  # Specifying the box we wish to use
  config.vm.box = "bento/centos-7.3"
  # Adding Bridged Network Adapter
  nodeCount.times do |i|
    id = i+1
    config.vm.define "vm#{id}" do |node|
      node.vm.network :private_network, ip: "#{privateSubnet}.#{privateStartingIp + id}", :netmask => "255.255.255.0"
      node.vm.hostname = "#{tag}#{id}"
      node.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
      end
      node.vm.provision 'customscript', type: :shell, :inline => $conf_env
    end
  end
end
