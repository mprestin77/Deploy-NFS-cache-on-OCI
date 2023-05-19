#!/bin/bash
set -x
# Get a list of local NVMe disks
DRIVESLIST=$(find /dev/nvme* -type b | xargs)
NUMDRIVES=$(echo $DRIVESLIST | wc -w)
echo "Detected $NUMDRIVES drives. Names: $DRIVESLIST."

if [ $NUMDRIVES -gt 0 ]; then
        echo "Found attached SSD device(s), initializing FS-Cache..."
        if [ ! -e /dev/md0 ]; then
                # Make RAID-0 array of attached Local SSDs
                echo "Creating RAID array from Local SSDs..."
                mdadm --create /dev/md0 --level=0 --force --quiet --raid-devices=$NUMDRIVES $DRIVESLIST --force
                echo "Finished creating RAID array from Local SSDs."
        fi
fi

# Create ext4 filesystem on RAID-0
mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/md0

# Install and enable FS-Cache
dnf install cachefilesd -y
systemctl enable cachefilesd

# Set selinux to permissive for FS-Cache 
semanage permissive -a cachefilesd_t
semanage permissive -a cachefiles_kernel_t

# Mount RAID-0 filesystem to the default FS-Cache location /var/cache/fscache
mount -o discard,defaults,nobarrier /dev/md0 /var/cache/fscache

# Create a permanent mount of /var/cache/fscache
sudo sh -c 'echo "/dev/md0 /var/cache/fscache ext4 defaults,noatime,_netdev 0 2" >> /etc/fstab'

# Start FS-Cache deamon
systemctl start cachefilesd

# Check the status of FS-Cache daemon
if systemctl is-active --quiet cachefilesd; then
  echo "cachefilesd started"
else
  echo "ERROR: cachefilesd failed to start"
  exit 1
fi

# Start NFS Server
systemctl enable nfs-server
systemctl start nfs-server
if systemctl is-active --quiet nfs-server; then
  echo "nfs-server started"
else
  echo "ERROR: nfs-server failed to start"
  exit 1
fi

# Open NFS ports in Linux FW
setenforce 0
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --reload
setenforce 1
echo "Linux firewall is updated"

