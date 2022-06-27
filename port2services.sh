#!/bin/bash
rm -rf nmapresult
mkdir nmapresult
cat ips|while read line
do
#	rm -rf *.txt
#	echo $line
	ipmin=$(ipcalc $line|grep HostMin|cut -d" " -f4|cut -d"." -f4)
	ipmax=$(ipcalc $line|grep HostMax|cut -d" " -f4|cut -d"." -f4)
	ip3=$(echo $line|awk -F"." '{print($1"."$2"."$3)}')
	for i in `seq $ipmin $ipmax`
	do
		echo $ip3.$i >>$ip3.txt
	done
	cat $ip3.txt|while read ip
	do
		masscan -p 1-65535 --rate=2000 $ip >>masscan$ip.txt
		ports=$(cat masscan$ip.txt|sed 's#/# #g'|awk '{print$4}' |xargs -n 100|sed 's# #,#g')
		echo "——————————————————————$ip————————————————————————————————">>nmapresult/nmap_services
		nmap -A -p $ports $ip >>nmapresult/nmap_services
		rm -rf masscan$ip.txt
	done
rm -rf *.txt
done
