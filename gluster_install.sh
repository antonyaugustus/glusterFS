#!/usr/bin/env bash

unix_os=$(cat /etc/os-release|grep LIKE)

if [[ ${unix_os} != *"rhel"* ]]; then
  echo "Invalid os. Recommended to run on RHEL"
  exit 1 
fi

wget -q "http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo"
cp virtualbox.repo /etc/yum.repos.d/

yum install epel-release -y
yum update -y
yum install -y gcc dkms make qt libgomp patch kernel-headers kernel-devel binutils glibc-headers glibc-devel font-forge
yum install -y VirtualBox-5.1 https://releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1_x86_64.rpm
/usr/lib/virtualbox/vboxdrv.sh setup

if [ ! -d ~/test-vagrant ]; then
  mkdir ~/test-vagrant
else
  rm -rf ~/test-vagrant && mkdir ~/test-vagrant
fi

cp Vagrantfile ~/test-vagrant
cd ~/test-vagrant
vagrant up

vagrant ssh vm1 -c "sudo gluster volume create gv0 replica 2 arbiter 1 transport tcp vm1:/home/vagrant/bricks/gv0 vm2:/home/vagrant/bricks/gv0 vm3:/home/vagrant/bricks/gv0 force"
vagrant ssh vm1 -c "sudo gluster volume start gv0"
vagrant ssh vm1 -c "mount -t glusterfs vm1:/gv0 /mnt"
vagrant ssh vm1 -c "for i in \$(seq -w 1 10); do cp -rp /var/log/messages /mnt/copy-test-\$i; done"
vagrant ssh vm1 -c "ls -lA /mnt |wc -l"
