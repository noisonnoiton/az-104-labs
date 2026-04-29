#!/bin/bash
set -e

# --- Format and mount data disk (LUN 0 → /dev/sdc on Azure) -----------------
if [ -b /dev/sdc ]; then
  parted /dev/sdc --script mklabel gpt mkpart primary ext4 0% 100%
  sleep 2
  mkfs.ext4 /dev/sdc1
  mkdir -p /mnt/data
  mount /dev/sdc1 /mnt/data
  echo '/dev/sdc1 /mnt/data ext4 defaults,nofail 0 2' >> /etc/fstab
fi

# --- Install nginx -----------------------------------------------------------
apt-get update -y
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

echo "<h1>Lab 08 - $(hostname)</h1><p>Data disk mounted at /mnt/data</p>" \
  > /var/www/html/index.html
