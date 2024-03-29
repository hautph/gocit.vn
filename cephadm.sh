#!/bin/bash

############################################################
# CephAdmin Install Script for Debian 11 (Bullseye)
# 
# run as sudo 
############################################################

# determine if we run as sudo
userid="${SUDO_USER:-$USER}"
if [ "$userid" == 'root' ]
  then 
    echo "Please run the setup as sudo and not as root!"
    exit 1
fi
if [ "$EUID" -ne 0 ]
  then 
    echo "Please run setup as sudo!"
    exit 1
fi

echo "################################################"
echo " installing cephadm on deployment-host only...."
echo "################################################"
#curl --silent --remote-name --location https://github.com/ceph/ceph/raw/pacific/src/cephadm/cephadm
#wget https://raw.githubusercontent.com/ceph/ceph/quincy/src/cephadm/cephadm
wget https://raw.githubusercontent.com/hautph/gocit.vn/master/cephadm
mv cephadm /usr/local/bin
chmod +x /usr/local/bin/cephadm
mkdir -p /etc/ceph

# add ceph common tools
#cephadm add-repo --release pacific
cephadm add-repo --release quincy
cephadm install ceph-common
