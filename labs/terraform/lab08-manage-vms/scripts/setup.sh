#!/bin/bash
set -e

# --- Format and mount data disk (LUN 0 → /dev/sdc on Azure) -----------------
if [ -b /dev/sdc ] && ! blkid /dev/sdc1 &>/dev/null; then
  parted /dev/sdc --script mklabel gpt mkpart primary ext4 0% 100%
  sleep 2
  mkfs.ext4 /dev/sdc1
fi

if [ -b /dev/sdc1 ] && ! mountpoint -q /mnt/data; then
  mkdir -p /mnt/data
  mount /dev/sdc1 /mnt/data
  grep -q '/dev/sdc1' /etc/fstab || echo '/dev/sdc1 /mnt/data ext4 defaults,nofail 0 2' >> /etc/fstab
fi

# --- Create sample file on data disk ----------------------------------------
mkdir -p /mnt/data/files
cat > /mnt/data/files/hello.txt <<'EOF'
AZ-104 Lab 08 — Data Disk Verification
=======================================
This file was created on the data disk (/mnt/data).
If you can download this file via the browser, the data disk is properly
mounted and nginx is serving it correctly.

Host: $(hostname)
Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
EOF
# Resolve variables inside the file
sed -i "s/\$(hostname)/$(hostname)/g" /mnt/data/files/hello.txt
sed -i "s/\$(date -u +\"%Y-%m-%dT%H:%M:%SZ\")/$(date -u +"%Y-%m-%dT%H:%M:%SZ")/g" /mnt/data/files/hello.txt

# --- Install nginx -----------------------------------------------------------
apt-get update -y
apt-get install -y nginx
systemctl enable nginx
systemctl start nginx

# --- Configure nginx: serve /mnt/data/files at /files ------------------------
cat > /etc/nginx/sites-available/default <<'NGINX'
server {
    listen 80 default_server;
    server_name _;

    root /var/www/html;
    index index.html;

    location /files/ {
        alias /mnt/data/files/;
        autoindex on;
    }
}
NGINX
systemctl reload nginx

# --- Generate index.html -----------------------------------------------------
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Lab 08</title></head>
<body>
<h1>Lab 08 - $(hostname)</h1>
<p>Data disk mounted at <code>/mnt/data</code></p>
<h2>Download test file from data disk</h2>
<ul>
  <li><a href="/files/hello.txt">hello.txt</a> — text file on data disk</li>
</ul>
</body></html>
HTML
