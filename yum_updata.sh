#!/usr/bin/bash

dev=$(nmcli device show |grep GENERAL.DEVICE | awk '{print $2}'| grep "^e")

nmcli connection up $dev

if [ $UID -ne 0 ];then
	echo -e "\e[1;31m 你还没有权限 请以root用户执行！\e[0m"
	exit
else
	echo -e "\e[1;31m 当前root用户 \e[0m" 
fi

yum repolist
yum install wget -y

echo -e "\e[1;31m 开始备份yum源 \e[0m"
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
echo -e "\e[1;31m 正在清楚原先yum仓库 \e[0m"
yum clean all

echo -e "\e[1;31m 正在重新建立yum仓库 \e[0m" 
yum makecache

yum update -y

reboot
