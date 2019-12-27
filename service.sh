#!/bin/bash
white="\e[0m"
red="\e[1;31m"

if [ $UID -ne 0 ];then
	echo -e "\e[1;31m 你还没有权限 请以root用户执行！\e[0m"
	exit
else
	echo -e "\e[1;32m 当前root用户 \e[0m" 
fi

selinux-off () {
	echo -e "\e[1;31m 正在设置SELINUX为关闭状态！\e[0m"
	sed -ri '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
}

yum_update () {
	dev=$(nmcli connection show | sed -rn '2p' | awk '{print $1}')
	nmcli connection up $dev;

	if [ $? -ne 0 ]; then
		exit;
	fi

	echo -e "\e[1;31m 开始备份yum源 \e[0m"
	mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
	wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

	echo -e "\e[1;31m 正在清除原先yum仓库 \e[0m"
	yum clean all

	echo -e "\e[1;31m 正在重新建立yum仓库 \e[0m" 
	yum makecache

	echo -e "\e[1;31m 正在更新软件 \e[0m" 
	yum update -y

	echo -en "\e[1;31m"
	read -p "是否重启[yes/no]:" flag
	echo -en "\e[0m"

	case "$flag" in 
	y|''|yes)
		reboot
		;;
	*)
		echo "exit"
		exit
		;;
	esac
}

help () {
	echo -e "${red} 此命令是有关于Service的安装$white"
	echo -e " sys install mariadb 安装Mariadb数据库 "
	echo -e " sys install httpd   安装Apache Web服务器 "
	echo -e " sys install nginx   安装Nginx  Web服务器 "
	echo -e "${red} start 和 stop  ... 选项 ... $white"
	echo -e " sys start network 开启网络连接 \n sys stop  network 关闭网络连接"
	echo -e " sys start nginx   开启Nginx  Web服务器 \n sys stop  nginx   关闭Nginx  Web服务器 "
	echo -e " sys start httpd   开启Apache Web服务器 \n sys stop  httpd   关闭Apache Web服务器 "
	echo -e "${red} 系统命令 $white"
	echo -e " sys -r 重新启动 \n sys -x 挂起"
	echo -e " sys -m 字符界面 "
	echo -e " sys -g 图形界面 "
	echo -e " sys selinux-off 关闭SELinux "
	echo -e " sys yum_update  将yum源更新为阿里云源 \e[1;36mTip：更改之前请将selinux关闭.\e[0m"
}

httpd () {
	dev=$(nmcli connection show | sed -rn '2p' | awk '{print $1}')
	nmcli connection up $dev;

	if [ $? -ne 0 ]; then
		exit;
	fi

	yum install httpd -y;

	if [[ $? -eq 0 ]]; then
		echo -e "${red} Apache Web服务器安装成功,请开始后续操作... $white"	
	fi

}

mariadb () {
	dev=$(nmcli connection show | sed -rn '2p' | awk '{print $1}')
	nmcli connection up $dev;

	if [ $? -ne 0 ]; then
		exit;
	fi

	yum install epel-release.noarch -y;

	cat  >/etc/yum.repos.d/Mariadb.repo <<-EOF
# MariaDB 10.4 CentOS repository list - created 2019-12-05 14:48 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
	EOF

	yum install MariaDB-server MariaDB-client -y;

	if [[ $? -eq 0 ]]; then
		echo -e "${red} Mariadb数据库安装完成，密码设置请自行更改... $white"
	fi

}

nginx () {
	dev=$(nmcli connection show | sed -rn '2p' | awk '{print $1}')
	nmcli connection up $dev;

	if [ $? -ne 0 ]; then
		exit;
	fi

	yum install epel-release.noarch -y;

	cat >/etc/yum.repos.d/nginx.repo <<-EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
	EOF

	yum install nginx -y;

	if [[ $? -eq 0 ]]; then
		echo -e "${red} Nginx Web服务器安装完成，站点设置请自行更改... $white"
	fi

}



#判断sys命令后面有无参数
if [[ -z $1 ]];then
	echo -e "${red} 提示: 请输入后置参数$white."
fi

# 参数-h显示出帮助
if [[ $1 == -h || $1 == -help || $1 == --help ]]; then
	help
fi

if [[ $1 == -r ]]; then
	reboot;
fi

if [[ $1 == -x ]]; then
	systemctl suspend;
fi

if [[ $1 == selinux-off ]]; then
	selinux-off
fi

if [[ $1 == yum_update ]]; then
	yum_update
fi

if [[ $1 == -g ]]; then
	systemctl isolate graphical.target;
fi

if [[ $1 == -m ]]; then
	systemctl isolate multi-user.target;
fi

# start 命令
if [[ $1 == start ]]; then
{
	if [[ -n $2 ]];then
	{
		case $2 in
		network)
			systemctl start network;
			if [ $? -eq 0 ] ;then
				echo -e "网络连接成功"
			else
				echo -e "网络连接失败"
			fi
			;;
		nginx)
			systemctl start nginx;
			if [ $? -eq 0 ] ;then
				echo -e "Nginx启动成功"
			else
				echo -e "Nginx启动失败"
			fi
			;;
		httpd)
			systemctl start httpd;
			if [ $? -eq 0 ] ;then
				echo -e "Apache启动成功"
			else
				echo -e "Apache启动失败"
			fi
			;;
			
		esac
	}
	fi
}
fi



# stop 命令
if [[ $1 == stop ]]; then
{
	if [[ -n $2 ]];then
	{
		case $2 in
		network)
			systemctl stop network;
			if [ $? -eq 0 ] ;then
				echo -e "网络连接成功关闭"
			else
				echo -e "关闭网络连接失败"
			fi
			;;
		nginx)
			systemctl stop nginx;
			if [ $? -eq 0 ] ;then
				echo -e "Nginx关闭成功"
			else
				echo -e "Nginx关闭失败"
			fi
			;;
		httpd)
			systemctl stop httpd;
			if [ $? -eq 0 ] ;then
				echo -e "Apache关闭成功"
			else
				echo -e "Apache关闭失败"
			fi
			;;

		esac
	}
	fi
}
fi




if [[ $1 == install ]];then
{
	echo "hello world"
	if [[ -n $2 ]];then
		echo "正在安装"
		case $2 in
		mariadb)
			echo "installed maridb"; mariadb ;
			;;
		httpd)
			echo "installed httpd"; httpd ;
			;;
		nginx)
			echo "installed nginx"; nginx ;
			;;
		
		esac
	else
		echo -e "${red}提示: 请输入后置参数$white."
	fi
}
else
	:
fi

