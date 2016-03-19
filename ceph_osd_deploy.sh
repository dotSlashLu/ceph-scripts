#!/bin/bash
#author: zhangqiang <zhangqiang@meizu.com>

DATA_PATH="/data/osd"
CLUSTER_NAME="ceph"

fsid="$(grep fsid conf/ceph.conf | gawk '{print $3}')"

if ! stat $DATA_PATH > /dev/null 2>&1; then
    mkdir $DATA_PATH
fi

fs_type=$(mount | grep "^$(df -Pk $DATA_PATH | head -n 2 | tail -n 1 | cut -f 1 -d ' ') " | cut -f 5 -d ' ')

cp -r ./conf/ /etc/ceph
cp -r ./lib/ /var/lib/ceph

echo "deploying ceph-osd for cluster $CLUSTER_NAME - $fsid, \
data path $DATA_PATH, fs type $fs_type"
echo

mkdir /var/lib/ceph/osd
ceph-disk prepare --cluster $CLUSTER_NAME --cluster-uuid $fsid \
    --fs-type $fs_type $DATA_PATH
ceph-disk activate $DATA_PATH
