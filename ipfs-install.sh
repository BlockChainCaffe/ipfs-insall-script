#!/bin/bash
#################################################
#
#   IPFS Install Script for Ubuntu 16.04 and up
#
#################################################

#################################################
# Download and install
DIST="https://dist.ipfs.io/go-ipfs"
DIR=$(mktemp -d)
cd $DIR
VERSION=$(wget -O - $DIST/versions |tail -1)
FILE="go-ipfs_"$VERSION"_linux-amd64.tar.gz"
wget "$DIST/$VERSION/$FILE"
tar -zxf $FILE
cd go-ipfs
./install.sh
cd /tmp
rm -Rf $DIR

#################################################
# Run as a service
apt-get install runit
adduser --system --group --home /var/lib/ipfs ipfs
mkdir -p /var/lib/ipfs
chown ipfs:ipfs /var/lib/ipfs

cat > /etc/systemd/system/ipfs.service <<EOF
[Unit]
After=network.target
Requires=network.target
Description="ipfs daemon"

[Service]
Type=simple
User=ipfs
RestartSec=1
Restart=always
PermissionsStartOnly=true
Nice=18
Environment=IPFS_PATH=/var/lib/ipfs
Environment=HOME=/var/lib/ipfs
LimitNOFILE=8192
Environment=IPFS_FD_MAX=8192
EnvironmentFile=-/etc/sysconfig/ipfs
StandardOutput=journal
WorkingDirectory=/var/lib/ipfs
ExecStartPre=-/usr/sbin/adduser --system --group --home /var/lib/ipfs ipfs
ExecStartPre=-/bin/mkdir /var/lib/ipfs
ExecStartPre=-/bin/chown ipfs:ipfs /var/lib/ipfs
ExecStartPre=-/bin/chmod ug+rwx /var/lib/ipfs
ExecStartPre=-/usr/bin/chpst -u ipfs /usr/local/bin/ipfs init --profile=badgerds
ExecStartPre=-/usr/bin/chpst -u ipfs /usr/local/bin/ipfs config profile apply server
ExecStartPre=-/usr/bin/chpst -u ipfs /usr/local/bin/ipfs config profile apply local-discovery
ExecStartPre=-/usr/bin/chpst -u ipfs /usr/local/bin/ipfs config Datastore.StorageMax "4000GB"
ExecStart=/usr/local/bin/ipfs daemon --enable-namesys-pubsub --enable-pubsub-experiment

[Install]
WantedBy=multi-user.target
EOF

#################################################
# Start
systemctl enable ipfs
systemctl start ipfs
