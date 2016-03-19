#!/bin/bash
# author: zhangqiang <zhangqiang@meizu.com>
mkdir /etc/ceph

IP_PREFIX=10.3
CLUSTER_NAME=ceph
host=`hostname -s`

# ip=$IP_PREFIX.`hostname | gawk -F '-' '{print $5}'`
ip=`ip a | grep '10.3' | gawk '{print $2}' | gawk -F"/" '{print $1}'`
echo "got ip $ip"

fsid=`uuidgen`
if [ -e $fsid ]; then
    echo "can't get uuid"
    exit;
fi
echo "got fsid $fsid"

echo "writing conf"
echo -e "fsid = $fsid               \n\
mon_initial_members = `hostname -s` \n\
ms_bind_ipv6 = false                \n\
mon_host = $ip                      \n\
filestore_xattr_use_omap = true     \n
" > /etc/ceph/$CLUSTER_NAME.conf

echo "generating keyrings"
ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool --create-keyring /etc/ceph/$CLUSTER_NAME.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring

echo
echo "generating mon map"
monmaptool --create --add $host $ip --fsid $fsid /tmp/monmap --clobber
mkdir -p /var/lib/ceph/mon/ceph-$host
ceph-mon --mkfs -i $host --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

echo
echo "writing conf"
echo -e "auth cluster required = cephx \n\
auth service required = cephx   \n\
auth client required = cephx    \n\
osd journal size = 128          \n\
osd pool default size = 2       \n\
osd pool default min size = 1   \n\
osd pool default pg num = 100   \n\
osd pool default pgp num = 100  \n\
osd crush chooseleaf type = 1" >> /etc/ceph/$CLUSTER_NAME.conf

echo "starting ceph mon"
touch /var/lib/ceph/mon/ceph-$host/sysvinit
touch /var/lib/ceph/mon/ceph-$host/done
/etc/init.d/ceph start mon.$host

ceph -s

echo
echo "copy config to pwd for deploying other daemons"
sleep 10
cp -r /var/lib/ceph/ ./lib
cp -r /etc/ceph/ ./conf
