#!/bin/bash
# author: zhangqiang <zhangqiang@meizu.com>

# install epel repo
# and fix epel repo url
su -c 'rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm'
sed -i "s/mirrorlist=https/mirrorlist=http/" /etc/yum.repos.d/epel.repo

# update python 2.6.6-36 to 2.6.6-64
yum update -y python python-libs

# import ceph repo key
rpm --import 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc'

# add ceph repos
cat > /etc/yum.repos.d/ceph.repo <<- EOM
[ceph]
name=Ceph packages for \$basearch
baseurl=http://download.ceph.com/rpm/el6/\$basearch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc
EOM
cat > /etc/yum.repos.d/ceph-extras.repo <<- EOM
[ceph-extras]
name=Ceph Extras Packages
baseurl=http://ceph.com/rpm-hammer/el6/\$basearch
enabled=1
priority=2
gpgcheck=1
type=rpm-md
gpgkey=https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc
EOM

# yum install -y ceph ceph-mds ceph-fuse
