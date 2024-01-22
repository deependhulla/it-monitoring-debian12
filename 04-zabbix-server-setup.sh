#!/bin/bash

wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian12_all.deb -O /tmp/zabbix-release_6.4-1+debian12_all.deb

dpkg -i /tmp/zabbix-release_6.4-1+debian12_all.deb
apt update
apt -y upgrade
apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent


MYSQLPASSVPOP=`pwgen -c -1 8`
echo $MYSQLPASSVPOP > /usr/local/src/mariadb-zabbix-pass
echo "zabbix mariadb password in /usr/local/src/mariadb-zabbix-pass"

sed -i "s/# DBPassword=/DBPassword=$MYSQLPASSVPOP/" /etc/zabbix/zabbix_server.conf

echo "create database zabbix character set utf8mb4 collate utf8mb4_bin" | mysql -uroot
echo "GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost IDENTIFIED BY '$MYSQLPASSVPOP'" with grant option  | mysql -uroot
mysqladmin -uroot reload
mysqladmin -uroot refresh
echo "set global log_bin_trust_function_creators = 1" | mysql -uroot
echo "Importing DB ..will take few min..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uroot zabbix

echo "set global log_bin_trust_function_creators = 0" | mysql -uroot

/bin/cp -pR /usr/share/zabbix/conf/zabbix.conf.php.example /etc/zabbix/web/zabbix.conf.php

ZPASSVPOP=`pwgen -c -1 8`
echo $ZPASSVPOP > /usr/local/src/zabbix-Admin-pass
echo "Admin password in /usr/local/src/zabbix-Admin-pass"
cat /usr/local/src/zabbix-Admin-pass

ZPASSX=`htpasswd -bnBC 10 zabbix $ZPASSVPOP | tr -d '\n'| sed s/zabbix://g`
echo "update zabbix.users set passwd=('$ZPASSX')  where username='Admin';" | mysql -uroot

/bin/rm /var/www/html/index.html  2>/dev/null
/bin/cp extra-files/index.php /var/www/html/

systemctl restart zabbix-server zabbix-agent apache2
systemctl enable zabbix-server zabbix-agent apache2 
