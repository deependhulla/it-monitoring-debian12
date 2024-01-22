#!/bin/bash


ZPASSVPOP=`pwgen -c -1 8`
echo $ZPASSVPOP > /usr/local/src/zabbix-Admin-pass
echo "zabbix : Admin password in /usr/local/src/zabbix-Admin-pass"
cat /usr/local/src/zabbix-Admin-pass

ZPASSX=`htpasswd -bnBC 10 zabbix $ZPASSVPOP | tr -d '\n'| sed s/zabbix://g`
echo $ZPASSX
echo "update zabbix.users set passwd=('$ZPASSX')  where username='Admin';" | mysql -uroot
