#!/bin/bash
#author: zhangqiang <zhangqiang@meizu.com>

DATA_PATHS=("/data/data0" "/data/data1" "/data/data2" \
            "/data/data3" "/data/data4" "/data/data5" \
            "/data/data6" "/data/data7" "/data/data8" \
            "/data/data9")
CLUSTER_NAME="ceph"

cp -r ./conf/ /etc/ceph
cp -r ./lib/ /var/lib/ceph
mkdir /var/lib/ceph/osd 2>/dev/null

fsid="$(grep fsid conf/ceph.conf | gawk '{print $3}')"
echo "fsid: $fsid"

for DATA_PATH in ${DATA_PATHS[@]}; do
    # remount disk with user_xattr option
    partition=$(mount | grep $DATA_PATH | gawk '{print $1}')
    umount $partition
    mount -o user_xattr $partition $DATA_PATH

    if ! stat $DATA_PATH/ceph > /dev/null 2>&1; then
        mkdir $DATA_PATH/ceph
    fi

    fs_type=$(mount | grep "^$(df -Pk $DATA_PATH | head -n 2 | tail -n 1 | cut -f 1 -d ' ') " | cut -f 5 -d ' ')


    echo "deploying ceph-osd for cluster $CLUSTER_NAME - $fsid, \
    data path $DATA_PATH/ceph, fs type $fs_type"
    echo

    ceph-disk prepare --cluster $CLUSTER_NAME --cluster-uuid $fsid \
        --fs-type $fs_type $DATA_PATH/ceph
    ceph-disk activate $DATA_PATH/ceph
    echo "=========="
done
