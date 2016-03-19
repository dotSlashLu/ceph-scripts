if [ ! -d /etc/ceph ]; then
    cp ./conf /etc/ceph
    cp ./lib /var/lib/ceph
fi

IP_PREFIX=10.3
CLUSTER_NAME=ceph
MON_IDX=2


host=`hostname -s`
fsid=$(cat conf/ceph.conf | gawk '{if($1=="fsid"){print $3}}')
echo "got fsid $fsid"

ip=$IP_PREFIX.`hostname | gawk -F '-' '{print $5}'`
echo "got ip $ip"

# mon_idx=$(grep "\[mon." /etc/ceph/ceph.conf | tail -1 | sed 's/[^0-9]*//g')
# if [ -z $mon_idx ]; then 
#     # because we already have a initial mon
#     # the index starts at 1
#     mon_idx=1
# else
#     mon_idx=$(($mon_idx+1))
# fi
# echo "got mon index: $mon_idx"
# data_dir=/var/lib/ceph/mon/ceph-$mon_idx
data_dir=/var/lib/ceph/mon/ceph-$MON_IDX


echo
echo "getting keyring"
ceph auth get mon. -o /tmp/keyring

echo
echo "getting mon map"
ceph mon getmap -o /tmp/monmap

echo
echo "mkfs"
ceph-mon --mkfs -i $MON_IDX --monmap /tmp/monmap --keyring /tmp/keyring

cat >> /etc/ceph/ceph.conf <<- EOM
[mon.$MON_IDX]
host = $host
public addr = $ip
EOM

echo
echo "starting ceph mon"
ceph mon add $MON_IDX $ip
ceph-mon -i $MON_IDX --public-addr $ip
