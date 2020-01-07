#!/usr/bin/bash

rm -rf /media/Services &>/dev/null

wget -O /media/Services https://raw.githubusercontent.com/GitHub-ZC/IECOXE/master/service.sh
chmod a+x /media/Services

sed -ri '$ialias sys="/media/Services"' /etc/bashrc
bash /etc/bashrc
source /etc/bashrc

echo -e "\e[1;31m  sys命令安装完成 -h 获取帮助  \e[0m"
