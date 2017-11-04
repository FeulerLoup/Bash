#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#	System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+
#	Description: Install Aria2c
#	Version: 1.0
#	Author: Jiuling
#=================================================

sh_ver="1.0"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[��Ϣ]${Font_color_suffix}"
Error="${Red_font_prefix}[����]${Font_color_suffix}"
Tip="${Green_font_prefix}[ע��]${Font_color_suffix}"
Separator_1="������������������������������������������������������������"
file="/etc/aria2"
aria2c_conf="${file}/aria2c.conf"
aria2c_log="/etc/aria2/aria2.log"
aria2c="/usr/bin/aria2c"

#������ϵͳ
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}
check_pid(){
	PID=`ps -ef| grep "aria2c"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}
check_pid_caddy(){
	PIDC=`ps -ef| grep "caddy"| grep -v grep| grep -v ".sh"| grep -v "init.d"| grep -v "service"| awk '{print $2}'`
}
check_installed_status(){
	[[ ! -e ${aria2c} ]] && echo -e "${Error} Aria2 û�а�װ������ !" && exit 1
	[[ ! -e ${aria2_conf} ]] && echo -e "${Error} Aria2 �����ļ������ڣ����� !" && [[ $1 != "un" ]] && exit 1
}
check_caddy_installed_status(){
	[[ ! -e /usr/local/bin/caddy ]] && echo -e "${Error} Caddy û�а�װ������ !" && exit 1
	[[ ! -e /etc/caddy/config.conf ]] && echo -e "${Error} Caddy �����ļ������ڣ����� !" && [[ $1 != "un" ]] && exit 1
}

# ��װ ����
Install_Aria2(){
	if [[ ${release} == "centos" ]]; then
		Centos_Install_Yum
		Centos_Install
		Download_Config
		Service_Aria2
	fi
		Debian_Install
		Download_Config
		Service_Aria2
}
Centos_Install_Yum(){
  wget https://copr.fedoraproject.org/coprs/rhscl/devtoolset-3/repo/epel-6/rhscl-devtoolset-3-epel-6.repo -O /etc/yum.repos.d/rhscl-devtoolset-3-epel-6.repo
  [[ ! -e "/etc/yum.repos.d/rhscl-devtoolset-3-epel-6.repo" ]] && echo -e "${Error} CentOS Repo �����ļ�����ʧ�� !" && exit 1
  yum install devtoolset-3-gcc devtoolset-3-gcc-c++ devtoolset-3-binutils devtoolset-3-gcc-gfortran sed -y
  echo -e "${Tip} ��ִ�� ${Green_font_prefix}scl enable devtoolset-3 bash${Font_color_suffix} ������ Centos ��װ Aria2 �����"
}
Centos_Install(){
	mkdir /etc/aria2
	cd /etc/aria2
  wget --no-check-certificate https://github.com/aria2/aria2/releases/download/release-1.33.0/aria2-1.33.0.tar.gz
    [[ ! -e "aria2-1.33.0.tar.gz" ]] && echo -e "${Error} Aria2Դ������ʧ�� !" && exit 1
  tar xzvf aria2-1.33.0.tar.gz
  cd aria2-1.33.0
  sed -i s"/1\, 16\,/1\, 64\,/" ./src/OptionHandlerFactory.cc
  ./configure
  make && make install
  echo -e "${Info} Aria2��װ�ɹ���"
}
Debian_Install(){
	apt-get update
	apt-get install -y vim git sed nettle-dev libgmp-dev libssh2-1-dev libc-ares-dev libxml2-dev zlib1g-dev libsqlite3-dev pkg-config libgpg-error-dev libssl-dev libexpat1-dev libxml2-dev libcppunit-dev autoconf automake autotools-dev autopoint libtool libxml2-dev openssl gettext
  git clone https://github.com/aria2/aria2.git
  cd aria2
  sed -i s"/1\, 16\,/1\, 64\,/" ./src/OptionHandlerFactory.cc
  autoreconf -i
  ./configure
  make
  make install
  echo -e "${Info} Aria2��װ�ɹ���"
}

# ��������
Service_Aria2(){
		if [[ ${release} = "centos" ]]; then
			mkdir -p /etc/aria2
      if ! wget --no-check-certificate https://raw.githubusercontent.com/Thnineer/Bash/master/init/aria2 -O /etc/init.d/aria2; then
			  echo -e "${Error} Aria2���� ����ű�����ʧ�� !" && exit 1
		  fi
		  chmod +x /etc/init.d/aria2
		  chkconfig --add aria2
		  chkconfig aria2 on
		  mkdir -p ~/.aria2
      chmod -R a+x ~/.aria2
		else
		  mkdir -p /etc/aria2
		  if ! wget --no-check-certificate https://raw.githubusercontent.com/Thnineer/Bash/master/init/aria2 -O /etc/init.d/aria2; then
			  echo -e "${Error} Aria2���� ����ű�����ʧ�� !" && exit 1
		  fi
      chmod +x /etc/init.d/aria2
      update-rc.d -f aria2 remove >/dev/null 2>&1
      update-rc.d aria2 defaults
      mkdir -p ~/.aria2
      chmod -R a+x ~/.aria2
    fi
}
# ���������ļ�
Download_Config(){
	cd /etc/aria2
	wget --no-check-certificate -N "https://raw.githubusercontent.com/Thnineer/Bash/master/init/aria2c.conf" -O /etc/aria2/aria2c.conf
	[[ ! -s "/etc/aria2/aria2c.conf" ]] && echo -e "${Error} Aria2 �����ļ�����ʧ�� !" && rm -rf "${file}" && exit 1
	wget --no-check-certificate -N "https://raw.githubusercontent.com/Thnineer/Bash/master/init/dht.dat" -O  /etc/aria2/dht.dat
	[[ ! -s "/etc/aria2/aria2c.conf" ]] && echo -e "${Error} Aria2 DHT�ļ�����ʧ�� !" && rm -rf "${file}" && exit 1
	echo '' > /etc/aria2/aria2.session
}
Set_SSL_Crt_Path(){
	echo "������SSL֤��·��(��Ҫpem��ʽ����)��"
	stty erase '^H' && read -p "(Ĭ��: /www/crt.pem):" Crt_Path
	[[ -z "${Crt_Path}" ]] && Crt_Path="/www/crt.pem"
  echo && echo ${Separator_1} && echo -e "	SSL֤��·�� : ${Green_font_prefix}${Crt_Path}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_SSL_Key_Path(){
	echo "������SSL˽Կ·����"
	stty erase '^H' && read -p "(Ĭ��: /www/key.key):" Key_Path
	[[ -z "${Key_Path}" ]] && Key_Path="/www/key.key"
  echo && echo ${Separator_1} && echo -e "	SSL˽Կ·�� : ${Green_font_prefix}${Key_Path}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Set_Url(){
	echo "��������վ��ַ������http����"
	stty erase '^H' && read -p "(Ĭ��: localhost):" Url
	[[ -z "${Url}" ]] && Url="localhost"
  echo && echo ${Separator_1} && echo -e "	SSL˽Կ·�� : ${Green_font_prefix}${Url}${Font_color_suffix}" && echo ${Separator_1} && echo
}
Ng_SSL_Filemanager_Install(){
	check_installed_status
	Set_Url
	curl https://getcaddy.com | bash -s personal http.filemanager
	[[ -e /usr/local/bin/caddy ]] && echo -e "${Info} Caddy��װ�ɹ���"
	while [ "$go" != 'y' ] && [ "$go" != 'n' ]
  do
	  read -p "��������վ��Aria2c������SSL��(y/n): " go;
  done
  if [ "$go" == 'n' ];then
	  No_SSL_Install;
  fi
  mkdir /etc/caddy
  wget --no-check-certificate -N "https://raw.githubusercontent.com/Thnineer/Bash/master/init/config.conf" -O /etc/caddy/config.conf
  [[ ! -s "/etc/caddy/config.conf" ]] && echo -e "${Error} Caddy �����ļ�����ʧ�� !" && rm -rf /etc/caddy/config.conf && exit 1
  sed -i 's,https:\/\/example.com,https:\/\/'${Url}',' /etc/caddy/config.conf
  mkdir /www && mkdir /www/wwwroot
  cd /www/wwwroot
  git clone https://github.com/mayswind/AriaNg-DailyBuild.git
  mv AriaNg-DailyBuild ariang
  [[ ! -s "/www/wwwroot/ariang/index.html" ]] && echo -e "${Error} AriaNG ����ʧ�� !" && rm -rf /www/wwwroot/ariang && exit 1
  sed -i 's/rpc-secure=false/rpc-secure=true/' /etc/aria2/aria2c.conf
  Set_SSL_Crt_Path
  Value="${Crt_Path}"
  Write_Dir
  sed -i 's:#rpc-certificate=\/path\/to\/certificate.pem:'${New_Value}':' /etc/aria2/aria2c.conf
  Set_SSL_Key_Path
  Value="${Key_Path}"
  Write_Dir
  sed -i 's:#rpc-certificate=\/path\/to\/certificate.key:'${New_Value}':' /etc/aria2/aria2c.conf
  echo -e "${Info} AriaNG Filemanager��װ�ɹ���SSL���óɹ���"
}
Write_Dir(){
	cat >/tmp/a<<-EOF
${Value}
EOF
New_Value=`sed 's:\/:\\/:g' /tmp/a`
rm -rf /tmp/a
}
No_SSL_Install(){
	mkdir /etc/caddy
  wget --no-check-certificate -N "https://raw.githubusercontent.com/Thnineer/Bash/master/init/config.conf" -O /etc/caddy/config.conf
  [[ ! -s "/etc/caddy/config.conf" ]] && echo -e "${Error} Caddy �����ļ�����ʧ�� !" && rm -rf /etc/caddy/config.conf && exit 1
  sed -i 's,http:\/\/example.com,http:\/\/'${Url}',' /etc/caddy/config.conf
  mkdir /www && mkdir /www/wwwroot
  cd /www/wwwroot
  git clone https://github.com/mayswind/AriaNg-DailyBuild.git
  mv AriaNg-DailyBuild ariang
  [[ ! -s "/www/wwwroot/ariang/index.html" ]] && echo -e "${Error} AriaNG ����ʧ�� !" && rm -rf /www/wwwroot/ariang && exit 1
  echo -e "${Info} AriaNG Filemanager��װ�ɹ���"
  
}
Start_aria2(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && echo -e "${Error} Aria2 �������У����� !" && exit 1
	/etc/init.d/aria2 start
}
Start_caddy(){
	check_caddy_installed_status
	check_pid_caddy
	[[ ! -z ${PIDC} ]] && echo -e "${Error} Caddy �������У����� !" && exit 1
	nohup caddy -conf="/etc/caddy/config.conf" >/dev/null 2>&1 &
	[[ ! -z ${PIDC} ]] && echo -e "${Info} Caddy �����ɹ���"
}
Stop_caddy(){
	check_caddy_installed_status
	check_pid_caddy
	[[ -z ${PIDC} ]] && echo -e "${Error} Aria2 û�����У����� !" && exit 1
  eval $(ps -ef | grep filemanager | grep -v grep | awk '{print "kill "$2}')
  [[ -z ${PIDC} ]] && echo -e "${Error} Caddyֹͣ�ɹ���"
}
Restart_caddy(){
	Stop_caddy
	Start_caddy
}	
Stop_aria2(){
	check_installed_status
	check_pid
	[[ -z ${PID} ]] && echo -e "${Error} Aria2 û�����У����� !" && exit 1
	/etc/init.d/aria2 stop
}
Restart_aria2(){
	check_installed_status
	check_pid
	[[ ! -z ${PID} ]] && /etc/init.d/aria2 stop
	/etc/init.d/aria2 start
}
View_Log(){
	[[ ! -e ${aria2_log} ]] && echo -e "${Error} Aria2 ��־�ļ������� !" && exit 1
	echo && echo -e "${Tip} �� ${Red_font_prefix}Ctrl+C${Font_color_suffix} ��ֹ�鿴��־" && echo
	tail -f ${aria2_log}
}
check_sys
[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && [[ ${release} != "centos" ]] && echo -e "${Error} ���ű���֧�ֵ�ǰϵͳ ${release} !" && exit 1
IP=`wget -qO- -t1 -T2 ipinfo.io/ip`      
echo && echo -e " Aria2 һ����װ����ű� ${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- By Jiuling ����IP��ַ��${IP} --
  
 ${Green_font_prefix}1.${Font_color_suffix} ��װ Aria2
 ${Green_font_prefix}2.${Font_color_suffix} Centos ��װ Aria2 �����
 ${Green_font_prefix}3.${Font_color_suffix} ��װ AriaNG �� Filemanager ������SSL(Caddy�����)
������������������������
 ${Green_font_prefix}4.${Font_color_suffix} ���� Aria2
 ${Green_font_prefix}5.${Font_color_suffix} ֹͣ Aria2
 ${Green_font_prefix}6.${Font_color_suffix} ���� Aria2
������������������������
 ${Green_font_prefix}7.${Font_color_suffix} ���� Caddy
 ${Green_font_prefix}8.${Font_color_suffix} ֹͣ Caddy
 ${Green_font_prefix}9.${Font_color_suffix} ���� Caddy
 ������������������������
 ${Green_font_prefix}10.${Font_color_suffix} �鿴 ��־��Ϣ
������������������������" && echo
if [[ -e ${aria2c} ]]; then
	check_pid
	if [[ ! -z "${PID}" ]]; then
		echo -e " ��ǰ״̬: ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Green_font_prefix}������${Font_color_suffix}"
	else
		echo -e " ��ǰ״̬: ${Green_font_prefix}�Ѱ�װ${Font_color_suffix} �� ${Red_font_prefix}δ����${Font_color_suffix}"
	fi
else
	echo -e " ��ǰ״̬: ${Red_font_prefix}δ��װ${Font_color_suffix}"
fi
echo
stty erase '^H' && read -p " ���������� [0-10]:" num
case "$num" in
	1)
	Install_Aria2
	;;
	2)
	Centos_Install
	;;
	3)
	Ng_SSL_Filemanager_Install
	;;
	4)
	Start_aria2
	;;
	5)
	Stop_aria2
	;;
	6)
	Restart_aria2
	;;
  7)
	Start_caddy
	;;
	8)
	Stop_caddy
	;;
	9)
	Restart_caddy
	;;
	10)
	View_Log
	;;
	*)
	echo "��������ȷ���� [1-5]"
	;;
esac