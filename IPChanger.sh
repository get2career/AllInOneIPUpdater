#!/bin/bash

echo -e "\e[0;31m\nTHIS SCRIPT CHECKS FOR THE FOLLOWING CONTROL PANELS AND UPDATE NEW IP ADDRESS! \n\e[0m"
echo -e "\e[0;32m1. HestiaCP
2. WHM/cPanel
3. CyberPanel 
4. Plesk\n \e[0m"

#OLD_IP=$1
#NEW_IP=$2

while true; do
	read -p "Enter Old IP address: " OLD_IP
	read -p "Enter New IP address: " NEW_IP
    if [ -z "$OLD_IP" ] || [ -z "$NEW_IP" ]; then
       echo -e "\e[0;31m\nPlease enter IP addresses again\n \e[0m"
       continue # Go to the top of the loop
    fi

    break # Valid input given so exit the loop.
done


yum_bin=$(which yum)
apt_bin=$(which apt)
dnf_bin=$(which dnf)

if [ ! -z "$yum_bin" ]; then
yum install whois -y > /dev/null 2>&1
elif [ ! -z "$apt_bin" ]; then
apt install whois -y > /dev/null 2>&1
elif [ ! -z "$dnf_bin" ]; then
dnf install whois -y > /dev/null 2>&1
fi



if [ -f /usr/local/hestia/conf/hestia.conf ]; then
		echo -e "\e[0;31m\nThis is Hestia Control Panel! \n\e[0m"
		v-update-sys-ip > /dev/null 2>&1
		STATUSS=`echo$?`
		service nginx restart > /dev/null 2>&1
		nginx_stat=`systemctl show -p ActiveState --value nginx`
		service apache2 restart > /dev/null 2>&1
		apache2_stat=`systemctl show -p ActiveState --value apache2`

	if [ "$nginx_stat" = "failed" ] || [ "$apache2_stat" = "failed" ]; then
		v-delete-sys-firewall
		v-add-sys-firewall
		grep -rl  "$OLD_IP" /etc/nginx /etc/apache2 /etc/nginx/conf.d /etc/apache2 /etc/apache2/conf.d /home/*/conf | xargs perl -p -i -e 's/$OLD_IP/$NEW_IP/g'
		service nginx restart > /dev/null 2>&1
		nginx_stat=`systemctl show -p ActiveState --value nginx`
		service apache2 restart > /dev/null 2>&1
		apache2_stat=`systemctl show -p ActiveState --value apache2`
		echo $nginx_stat $apache2_stat
	fi


	if [ "$nginx_stat" = "active" ] && [ "$apache2_stat" = "active" ]; then
		echo -e "\e[0;32m\nNginx is $nginx_stat 
		Apache is $apache2_stat
		IP address changed successfully \e[0m"
	fi


	if hostname |grep -iqs  ".ultasrv.net"; then
		fqdn=ultasrv.net
		curl -sk https://sh.$fqdn/cloud-init/ssl/$fqdn.key > /usr/local/hestia/ssl/certificate.key
		curl -sk https://sh.$fqdn/cloud-init/ssl/$fqdn.crt > /usr/local/hestia/ssl/certificate.crt
		systemctl restart hestia
		history -c
	fi


		v-list-users | awk '{ print $1 }' | grep -v "USER\|--" > /root/klem_users
		> /root/klem_domainss
		for i in `cat /root/klem_users`; do domainn=`v-list-web-domains $i | awk '{ print $1}' |grep -v "DOMAIN\|------"`; echo "$domainn" >> /root/klem_domainss ;done 
		> /root/klem_domains_uses_our_NS
		for i in `cat /root/klem_domainss`; do if whois $i  |grep "Name Server" |head -2| grep  -qsi ".ultahost.com"; then echo $i >> /root/klem_domains_uses_our_NS;  fi;  done
	if [ -s /root/klem_domains_uses_our_NS  ]; then
		echo -e "\e[0;31m\nPlease Update New IP address, $NEW_IP, for the following DOMAINS in DNS manager.\n\n \e[0m"
		cat /root/klem_domains_uses_our_NS
		history -c
	fi





elif [ -f /var/cpanel/cpanel.config ]; then
		echo -e "\e[0;31m\nThis is WHM/cPanel! \n\e[0m"
		/usr/local/cpanel/cpkeyclt
	if hostname |grep -iqs  ".ultasrv.net"; then
		fqdn=ultasrv.net
		curl -sk https://sh.$fqdn/cloud-init/ssl/$fqdn.key > /var/cpanel/ssl/cpanel/cpanel.pem
		curl -sk https://sh.$fqdn/cloud-init/ssl/$fqdn.crt >> /var/cpanel/ssl/cpanel/cpanel.pem
		systemctl restart cpanel
		history -c
	fi

		for i in `cat /etc/trueuserdomains |awk '{ print $2 }'`; do whmapi1 setsiteip ip=$NEW_IP user=$i; done && history -c
		cat /etc/userdatadomains |grep "==main==\|==addon==\|==parked==" | cut -d: -f1 > /root/klem_domainss
		> /root/klem_domains_uses_our_NS
		for i in `cat /root/klem_domainss`; do if whois $i  |grep "Name Server" |head -2| grep  -qsi ".ultahost.com"; then echo $i >> /root/klem_domains_uses_our_NS;  fi;  done
	if [ -s /root/klem_domains_uses_our_NS  ]; then
		echo -e "\e[0;31m\nPlease Update New IP address, $IIPP, for the following DOMAINS.\n\n \e[0m"
		cat /root/klem_domains_uses_our_NS
		history -c
	fi
		




elif [ -f /usr/local/CyberCP/CyberCP/settings.py ]; then

		curl -s https://api.ipify.org | tee /etc/cyberpanel/machineIP
		echo -e "\e[0;31m\n Cyberpanel IP changed \e[0m"
		cyberpanel listWebsitesPretty |awk '{ print $4 }' |grep -v "Domain\|^$" |grep -v ".ultasrv.net\|.ultasrv.com" > /root/klem_domainss
		> /root/klem_domains_uses_our_NS
		for i in `cat /root/klem_domainss`; do if whois $i  |grep "Name Server" |head -2| grep  -qsi ".ultahost.com"; then echo $i >> /root/klem_domains_uses_our_NS;  fi;  done
	if [ -s /root/klem_domains_uses_our_NS  ]; then
		echo -e "\e[0;31m\nPlease Update New IP address, $NEW_IP, for the following DOMAINS.\n\n \e[0m"
		cat /root/klem_domains_uses_our_NS
		history -c

	#if hostname |grep -iqs  ".ultasrv.net"; then 
		#fqdn=ultasrv.net
		#curl -sk https://sh.$fqdn/cloud-init/ssl/$fqdn.key > /usr/local/lscp/conf/key.pem
		#curl -sk https://sh.$fqdn/cloud-init/ssl/$fqdn.crt > /usr/local/lscp/conf/cert.pem
		#systemctl restart lscpd
		#history -c
	#fi
		




elif [ -f /usr/local/psa/admin/conf/panel.ini ]; then
		/usr/sbin/plesk bin ipmanage --auto-remap > /dev/null 2>&1
		STATUSS=`echo$?`
	if [ $STATUSS = "0" ]; then
		echo -e "\e[0;31m\nPlesk IP changed\n \e[0m"
		/usr/sbin/plesk bin ipmanage --remove $OLD_IP > /dev/null 2>&1
		plesk bin domain -l > /root/klem_domainss
		> /root/klem_domains_uses_our_NS
		for i in `cat /root/klem_domainss`; do if whois $i  |grep "Name Server" |head -2| grep  -qsi ".ultahost.com"; then echo $i >> /root/klem_domains_uses_our_NS;  fi;  done
		
		if [ -s /root/klem_domains_uses_our_NS  ]; then
			echo -e "\e[0;31m\nPlease Update New IP address, $NEW_IP, for the following DOMAINS.\n\n \e[0m"
			cat /root/klem_domains_uses_our_NS
			history -c
		fi
	else
		echo -e "\e[0;31m\nIP update in Plesk failed\n \e[0m"
	fi
fi
history -c
