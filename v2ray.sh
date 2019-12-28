#!/bin/bash

echo "start install v2ray"

command -v git;
if [ $? -ne 0 ] ;then
	yum install -y git;
fi

git clone https://github.com/GitHub-ZC/v2ray.git;

dir_path=$(pwd)/v2ray/v2ray

mkdir -p /etc/v2ray

mv ${dir_path}/config.json /etc/v2ray
mv ${dir_path}/v2ray.service /etc/systemd/system
mv ${dir_path} /usr/bin

chmod a+x /usr/bin/v2ray/v2ray
chmod a+x /usr/bin/v2ray/v2ctl

systemctl daemon-reload
systemctl start v2ray.service

rm -rf v2ray

echo "startde v2ray ..."
