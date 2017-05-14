#!/bin/bash

if [[ $USER != "root" ]]; then
	echo "Maaf, Anda harus menjalankan ini sebagai root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;
MYIP=$(wget -qO- ipv4.icanhazip.com);
MYIP2="s/xxxxxxxxx/$MYIP/g";
ether=`ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:`
if [[ $ether = "" ]]; then
        ether=eth0
fi

#vps="zvur";
vps="aneka";

#if [[ $vps = "zvur" ]]; then
	#source="http://"
#else
	source="https://raw.githubusercontent.com/elangoverdosis/deeniedoank"
#fi

# go to root
cd

# check registered ip
wget -q -O IP $source/debian7/IP.txt
if ! grep -w -q $MYIP IP; then
	echo "Maaf, hanya IP yang terdaftar yang bisa menggunakan script ini!"
	if [[ $vps = "zvur" ]]; then
		echo "Hubungi: editor ( elang overdoasis atau deeniedoank)"
	else
		echo "Hubungi: editor ( elang overdoasis atau deeniedoank)"
	fi
	rm -f /root/IP
	exit
fi

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local
#sed -i 's/net.ipv6.conf.all.disable_ipv6 = 0/net.ipv6.conf.all.disable_ipv6 = 1/g' /etc/sysctl.conf
#sed -i 's/net.ipv6.conf.default.disable_ipv6 = 0/net.ipv6.conf.default.disable_ipv6 = 1/g' /etc/sysctl.conf
#sed -i 's/net.ipv6.conf.lo.disable_ipv6 = 0/net.ipv6.conf.lo.disable_ipv6 = 1/g' /etc/sysctl.conf
#sed -i 's/net.ipv6.conf.eth0.disable_ipv6 = 0/net.ipv6.conf.eth0.disable_ipv6 = 1/g' /etc/sysctl.conf
#sysctl -p

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list $source/debian7/sources.list.debian7
wget http://www.dotdeb.org/dotdeb.gpg
wget http://www.webmin.com/jcameron-key.asc
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg
cat jcameron-key.asc | apt-key add -;rm jcameron-key.asc

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;
apt-get -y --purge remove dropbear*;
#apt-get -y autoremove;

# update
apt-get update;apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
echo "mrtg mrtg/conf_mods boolean true" | debconf-set-selections
#apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
vnstat -u -i $ether
service vnstat restart

# install screenfetch
cd
#wget $source/debian7/screenfetch-dev
#mv screenfetch-dev /usr/bin/screenfetch
#chmod +x /usr/bin/screenfetch
#echo "clear" >> .profile
#echo "screenfetch" >> .profile

#text gambar
apt-get install boxes

# text pelangi
sudo apt-get install ruby -y
sudo gem install lolcat

# text warna
cd
rm -rf /root/.bashrc
wget -O /root/.bashrc $source/debian7/.bashrc

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf $source/debian7/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Modified by elang overdosis n' yusuf ardiansyah</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf $source/debian7/vps.conf
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

#PASS=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1`;
#useradd -M -s /bin/false deenie11
#echo "deenie11:$PASS" | chpasswd
#echo "deenie11" >> pass.txt
#echo "$PASS" >> pass.txt
#cp pass.txt /home/vps/public_html/
#rm -f /root/pass.txt
cd

# install badvpn
wget -O /usr/bin/badvpn-udpgw $source/debian7/badvpn-udpgw
if [[ $OS == "x86_64" ]]; then
  wget -O /usr/bin/badvpn-udpgw $source/debian7/badvpn-udpgw64
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
#apt-get update;apt-get -y install snmpd;
wget -O /etc/snmp/snmpd.conf $source/debian7/snmpd.conf
wget -O /root/mrtg-mem $source/debian7/mrtg-mem.sh
chmod +x /root/mrtg-mem
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl $source/debian7/mrtg.conf >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
#sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
#sed -i '/Port 22/a Port 80' /etc/ssh/sshd_config
#sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
sed -i '$ i\Banner bannerssh' /etc/ssh/sshd_config
service ssh restart

# install dropbear
#apt-get -y update
#apt-get -y install dropbear
#sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
#sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
#sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
#echo "/bin/false" >> /etc/shells
#echo "/usr/sbin/nologin" >> /etc/shells
#service ssh restart
#service dropbear restart

apt-get install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=80/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 443"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
sed -i 's/DROPBEAR_BANNER=""/DROPBEAR_BANNER="bannerssh"/g' /etc/default/dropbear
service ssh restart
service dropbear restart

# upgrade dropbear 2014
apt-get install zlib1g-dev
wget https://matt.ucc.asn.au/dropbear/releases/dropbear-2016.74.tar.bz2
bzip2 -cd dropbear-2016.74.tar.bz2 | tar xvf -
cd dropbear-2016.74
./configure
make && make install
mv /usr/sbin/dropbear /usr/sbin/dropbear1
ln /usr/local/sbin/dropbear /usr/sbin/dropbear
service dropbear restart

# install vnstat gui
cd /home/vps/public_html/
wget $source/debian7/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i "s/eth0/$ether/g" config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array($ether);/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

#if [[ $ether = "eth0" ]]; then
#	wget -O /etc/iptables.conf $source/Debian7/iptables.up.rules.eth0
#else
#	wget -O /etc/iptables.conf $source/Debian7/iptables.up.rules.venet0
#fi

#sed -i $MYIP2 /etc/iptables.conf;
#iptables-restore < /etc/iptables.conf;

# block all port except
sed -i '$ i\iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -d 127.0.0.1 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 21 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 22 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 53 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 81 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 109 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 110 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 143 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 443 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 1194 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 3128 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 8000 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 8080 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp --dport 10000 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p udp -m udp --dport 53 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p udp -m udp --dport 2500 -j ACCEPT' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p udp -m udp -j DROP' /etc/rc.local
sed -i '$ i\iptables -A OUTPUT -p tcp -m tcp -j DROP' /etc/rc.local

# install fail2ban
apt-get update;apt-get -y install fail2ban;service fail2ban restart;

# Instal (D)DoS Deflate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'
q

# install squid3
apt-get -y install squid3
wget -O /etc/squid3/squid.conf $source/debian7/squid3.conf
sed -i $MYIP2 /etc/squid3/squid.conf;
service squid3 restart

# install webmin
cd
#wget -O webmin-current.deb http://prdownloads.sourceforge.net/webadmin/webmin_1.760_all.deb
wget -O webmin-current.deb $source/debian7/webmin-current.deb
dpkg -i --force-all webmin-current.deb
apt-get -y -f install;
#sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
rm -f /root/webmin-current.deb
apt-get -y --force-yes -f install libxml-parser-perl
service webmin restart
service vnstat restart

# install pptp vpn
wget $source/debian7/pptp.sh
chmod +x pptp.sh
./pptp.sh

# download script
cd
wget -O /usr/bin/benchmark $source/debian7/benchmark.sh
wget -O /usr/bin/speedtest $source/debian7/speedtest_cli.py
wget -O /usr/bin/ps-mem $source/debian7/ps_mem.py
wget -O /root/bannerssh $source/debian7/bannerssh
#wget -O /usr/bin/autokill $source/Debian7/autokill.sh
wget -O /usr/bin/dropmon $source/debian7/dropmon.sh
wget -O /usr/bin/menu $source/debian7/menu.sh
wget -O /usr/bin/user-active-list $source/debian7/user-active-list.sh
wget -O /usr/bin/user-add $source/debian7/user-add.sh
wget -O /usr/bin/user-add-pptp $source/debian7/user-add-pptp.sh
wget -O /usr/bin/user-del $source/debian7/user-del.sh
wget -O /usr/bin/disable-user-expire $source/debian7/disable-user-expire.sh
wget -O /usr/bin/delete-user-expire $source/debian7/delete-user-expire.sh
wget -O /usr/bin/banned-user $source/debian7/banned-user.sh
wget -O /usr/bin/user-expire-list $source/debian7/user-expire-list.sh
wget -O /usr/bin/user-gen $source/debian7/user-gen.sh
wget -O /usr/bin/userlimit.sh $source/debian7/userlimit.sh
wget -O /usr/bin/userlimitssh.sh $source/debian7/userlimitssh.sh
wget -O /usr/bin/user-list $source/debian7/user-list.sh
wget -O /usr/bin/user-login $source/debian7/user-login.sh
wget -O /usr/bin/user-pass $source/debian7/user-pass.sh
wget -O /usr/bin/user-renew $source/debian7/user-renew.sh
wget -O /usr/bin/clearcache.sh $source/debian7/clearcache.sh
wget -O /usr/bin/bannermenu $source/debian7/bannermenu
wget -O /usr/bin/menu-update-script-vps.sh $source/debian7/menu-update-script-vps.sh
cd

echo "*/30 * * * * root service dropbear restart" > /etc/cron.d/dropbear
echo "00 23 * * * root /usr/bin/disable-user-expire" > /etc/cron.d/disable-user-expire
echo "0 */12 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "00 01 * * * root echo 3 > /proc/sys/vm/drop_caches && swapoff -a && swapon -a" > /etc/cron.d/clearcacheram3swap
echo "*/20 * * * * root /usr/bin/clearcache.sh" > /etc/cron.d/clearcache1

#echo "@reboot root /usr/bin/user-limit" > /etc/cron.d/user-limit
#echo "@reboot root /usr/bin/autokill" > /etc/cron.d/autokill
#sed -i '$ i\screen -AmdS check /root/autokill' /etc/rc.local

# pendukung shc
cd
apt-get install yum
yum -y install make automake autoconf gcc gcc++
apt-get -y install build-essential
aptitude -y install build-essential
cd

#shc
wget $source/debian7/shc-3.8.7.tgz"
tar xvfz shc-3.8.7.tgz
clear
cd
echo "=========================================================="
echo "-------------------Tanggal Kadaluarsa MENU----------------"
echo "##########################################################"
echo -e "Wajib di isi bos yusuf ardiansyah" | boxes -d peek | lolcat

echo -e "Contoh Format Tanggal: 30/07/2018"
echo -e "Angka semua ya boss!" | lolcat
echo ""
read -p "Silahkan Ketikan Tanggal Kadaluarsa MENU: " deeniemenu
cd shc-3.8.7
make
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/menu
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/benchmark
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/speedtest
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/ps-mem
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/dropmon
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-active-list
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-add
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-add-pptp
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-del
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/disable-user-expire
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/delete-user-expire
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/banned-user
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-expire-list
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-gen
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/userlimit.sh
./shc -e $deeniemenu -m "maaf boss MENU ente sudah kadaluaraa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/userlimitssh.sh
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-list
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-login
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/user-pass
./shc -e $deeniemenu -m "Maaf boss MENU ente sudah kadaluarsa silahkan hubungi admin Deny siswanto atau Yusuf ardiansyah" -f /usr/bin/menu-update-script-vps.sh


clear
#./shc -e $deeniemenu -f /usr/local/bin/menu
#./shc -f /usr/local/bin/menu
cd
mv /usr/bin/menu.x /usr/bin/menu
mv /usr/bin/benchmark.x /usr/bin/benchmark
mv /usr/bin/speedtest.x /usr/bin/speedtest
mv /usr/bin/ps-mem.x /usr/bin/ps-mem
mv /usr/bin/dropmon.x /usr/bin/dropmon
mv /usr/bin/user-active-list.x /usr/bin/user-active-list
mv /usr/bin/user-add.x /usr/bin/user-add
mv /usr/bin/user-add-pptp.x /usr/bin/user-add-pptp
mv /usr/bin/user-del.x /usr/bin/user-del
mv /usr/bin/disable-user-expire.x /usr/bin/disable-user-expire
mv /usr/bin/delete-user-expire.x /usr/bin/delete-user-expire
mv /usr/bin/banned-user.x /usr/bin/banned-user
mv /usr/bin/user-expire-list.x /usr/bin/user-expire-list
mv /usr/bin/user-gen.x /usr/bin/user-gen
mv /usr/bin/userlimit.sh.x /usr/bin/userlimit.sh
mv /usr/bin/userlimitssh.sh.x /usr/bin/userlimitssh.sh
mv /usr/bin/user-list.x /usr/bin/user-list
mv /usr/bin/user-login.x /usr/bin/user-login
mv /usr/bin/user-pass.x /usr/bin/user-pass
mv /usr/bin/user-renew.x /usr/bin/user-renew
mv /usr/bin/menu-update-script-vps.sh.x /usr/bin/menu-update-script-vps.sh

cd
chmod +x /usr/bin/benchmark
chmod +x /usr/bin/speedtest
chmod +x /usr/bin/ps-mem
#chmod +x /usr/bin/autokill
chmod +x /usr/bin/dropmon
chmod +x /usr/bin/menu
chmod +x /usr/bin/user-active-list
chmod +x /usr/bin/user-add
chmod +x /usr/bin/user-add-pptp
chmod +x /usr/bin/user-del
chmod +x /usr/bin/disable-user-expire
chmod +x /usr/bin/delete-user-expire
chmod +x /usr/bin/banned-user
chmod +x /usr/bin/user-expire-list
chmod +x /usr/bin/user-gen
chmod +x /usr/bin/userlimit.sh
chmod +x /usr/bin/userlimitssh.sh
chmod +x /usr/bin/user-list
chmod +x /usr/bin/user-login
chmod +x /usr/bin/user-pass
chmod +x /usr/bin/user-renew
chmod +x /usr/bin/clearcache.sh
chmod +x /usr/bin/bannermenu
chmod +x /usr/bin/menu-update-script-vps.sh
cd
rm /usr/bin/benchmark.x.c
rm /usr/bin/speedtest.x.c
rm /usr/bin/ps-mem.x.c
rm usr/bin/dropmon.x.c
rm /usr/bin/menu.x.c
rm /usr/bin/user-active-list.x.c
rm /usr/bin/user-add.x.c
rm /usr/bin/user-add-pptp.x.c
rm /usr/bin/user-del.x.c
rm /usr/bin/disable-user-expire.x.c
rm /usr/bin/delete-user-expire.x.c
rm /usr/bin/banned-user.x.c
rm /usr/bin/user-expire-list.x.c
rm /usr/bin/user-gen.x.c
rm /usr/bin/userlimit.sh.x.c
rm /usr/bin/userlimitssh.sh.x.c
rm /usr/bin/user-list.x.c
rm /usr/bin/user-login.x.c
rm /usr/bin/user-pass.x.c
rm /usr/bin/user-renew.x.c
rm /usr/bin/menu-update-script-vps.sh.x.c
# hapus installan shc
rm -rf /root/shc-3.8.7
rm /root/shc-3.8.7.tgz

# swap ram
dd if=/dev/zero of=/swapfile bs=1024 count=1024k
# buat swap
mkswap /swapfile
# jalan swapfile
swapon /swapfile
#auto star saat reboot
wget $source/debian7/fstab
mv ./fstab /etc/fstab
chmod 644 /etc/fstab
sysctl vm.swappiness=10
#permission swapfile
chown root:root /swapfile 
chmod 0600 /swapfile
cd
#ovpn
wget -O openvpn.sh $source/debian7/openvpn.sh && chmod +x openvpn.sh && ./openvpn.sh
service openvpn restart

usermod -s /bin/false mail
echo "mail:deenie" | chpasswd
useradd -s /bin/false -M deenie11
echo "deenie11:deenie" | chpasswd
# finishing
chown -R www-data:www-data /home/vps/public_html
service cron restart
service nginx start
service php5-fpm start
service vnstat restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart
cd
rm -f /root/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

# info
clear
echo "Autoscript Edited elang overdosis and yusuf ardiansyah:" | tee log-install.txt
echo "=======================================================" | tee -a log-install.txt
echo "Service :" | tee -a log-install.txt
echo "---------" | tee -a log-install.txt
echo "OpenSSH  : 22, 143" | tee -a log-install.txt
echo "Dropbear : 443, 80" | tee -a log-install.txt
echo "Squid3   : 8080 limit to IP $MYIP" | tee -a log-install.txt
#echo "OpenVPN  : TCP 1194 (client config : http://$MYIP:81/client.ovpn)" | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300" | tee -a log-install.txt
echo "PPTP VPN : TCP 1723" | tee -a log-install.txt
echo "nginx    : 81" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Tools :" | tee -a log-install.txt
echo "-------" | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, rkhunter, nethogs: nethogs $ether" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Script :" | tee -a log-install.txt
echo "--------" | tee -a log-install.txt
echo "MENU"
echo "" | tee -a log-install.txt
echo "Fitur lain :" | tee -a log-install.txt
echo "------------" | tee -a log-install.txt
echo "Webmin         : http://$MYIP:10000/" | tee -a log-install.txt
echo "vnstat         : http://$MYIP:81/vnstat/ (Cek Bandwith)" | tee -a log-install.txt
echo "MRTG           : http://$MYIP:81/mrtg/" | tee -a log-install.txt
echo "Timezone       : Asia/Jakarta " | tee -a log-install.txt
echo "Fail2Ban       : [on]" | tee -a log-install.txt
echo "(D)DoS Deflate : [on]" | tee -a log-install.txt
echo "Block Torrent  : [off]" | tee -a log-install.txt
echo "IPv6           : [off]" | tee -a log-install.txt
#echo "Autolimit 2 bitvise per IP to all port (port 22, 143, 109, 110, 443, 1194, 7300 TCP/UDP)" | tee -a log-install.txt
echo "Auto Lock User Expire tiap jam 00:00" | tee -a log-install.txt
echo "Auto Reboot tiap jam 00:00 dan jam 12:00" | tee -a log-install.txt
echo "" | tee -a log-install.txt

if [[ $vps = "zvur" ]]; then
	echo "ALL SUPPORTED BY CLIENT VPS" | tee -a log-install.txt
else
	echo "ALL SUPPORTED BY TEAM HACKER" | tee -a log-install.txt
	
fi
echo "Credit to all developers script, Yusuf ardiansyah" | tee -a log-install.txt
echo "Thanks to Original Creator Kang Arie & Mikodemos" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Log Instalasi --> /root/log-install.txt" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "SILAHKAN REBOOT VPS ANDA !" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt
cd ~/
rm -f /root/cinta7.sh
rm -f /root/pptp.sh
rm -f /root/dropbear-2016.74.tar.bz2
rm -rf /root/dropbear-2016.74
rm -f /root/IP
