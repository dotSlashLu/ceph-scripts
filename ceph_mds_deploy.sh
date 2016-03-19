#!/bin/bash
#author: zhangqiang <zhangqiang@meizu.com>

DATA_PATH_PREFIX="/var/lib/ceph/mds"
MDS_IDX=1

if ! [ -f /etc/ceph/ceph.conf ]; then
    echo "no conf file found, might be a new ceph node, copying confs"
    cp -r ./conf/ /etc/ceph
    cp -r ./lib/ /var/lib/ceph
fi

# mds_idx=$(grep "\[mds." /etc/ceph/ceph.conf | tail -1 | sed 's/[^0-9]*//g')
# if [ -z $mds_idx ]; then 
#     mds_idx=0
# else
#     mds_idx=$(($mds_idx+1))
# fi
# echo 
# echo "got mds index: $mds_idx"

data_path="$DATA_PATH_PREFIX/mds-$MDS_IDX"


name=$(hostname -s)
mkdir -p $data_path

cat >> /etc/ceph/ceph.conf <<- EOM
[mds.$MDS_IDX]
mds data = $data_path 
keyring = $data_path/mds.$MDS_IDX.keyring
host = $name
EOM

echo "create keyring"
ceph auth get-or-create mds.$MDS_IDX mds 'allow ' osd 'allow *' mon 'allow rwx' > $data_path/mds.$MDS_IDX.keyring

echo
echo "starting mds"
service ceph start mds.$MDS_IDX
