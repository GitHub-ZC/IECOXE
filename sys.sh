#!/usr/bin/bash

rm -rf /media/Services &>/dev/null

wget -O /media/Services http://173.199.127.79/service.sh
chmod a+x /media/Services

sed -ri '$ialias sys="/media/Services"' /etc/bashrc
bash /etc/bashrc
source /etc/bashrc

echo -e "\e[1;31m  sys命令安装完成 -h 获取帮助  \e[0m"
