#!/usr/bin/bash
#系统管理工具
clear
while :
do



menu() {
cat <<-EOF
                 系统工具箱
	-------------------------------------------------
	|	q.quit					|
	|	h.help					|
	|	f.disk partition			|
	|	d.filesystem mount			|
	|	m.memory				|
	|	u.system load				|
	-------------------------------------------------
EOF
}

read -p "[$USER@$HOSTNAME $PWD]#" flag

case "$flag" in 
h)
	menu
	;;
f)
	fdisk -l
	;;
d)
	df -Th
	;;
m)
	free -m
	;;
u)
	uptime
	;;
q)
	exit
	;;
'')
	#echo -e "please input [h for help]:"
	;;
*)
	echo error
	;;
esac
done

