#!/bin/bash

export LANG=C
export LC_CTYPE=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

apt-get install -y apt-transport-https software-properties-common wget

cd /tmp/
wget -q https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c influxdata-archive_compat.key' | sha256sum -c && cat influxdata-archive_compat.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] https://repos.influxdata.com/debian stable main' > /etc/apt/sources.list.d/influxdata.list


mkdir -p /etc/apt/keyrings/ 2>/dev/null
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list

apt update 
apt -y install influxdb2 telegraf grafana

##back to main folder from /tmp
cd -

systemctl restart influxdb influxd
systemctl start grafana-server
systemctl enable --now -q grafana-server.service

ZPASSVPOP=`pwgen -c -1 8`
echo $ZPASSVPOP > /usr/local/src/influxdb-proxmox-pass
echo "Admin password in /usr/local/src/influxdb-proxmox-pass"
cat /usr/local/src/influxdb-proxmox-pass

influx setup --username 'proxmox' --password '$ZPASSVPOP' --org 'proxmox' --bucket 'proxmox' --force
influx user password --name 'proxmox' --password "$ZPASSVPOP"

ZTOKEN=`influx auth create --user 'proxmox' --org 'proxmox' --all-access --json | grep -oP '"token": "\K[^"]+'`
echo "$ZTOKEN" > /usr/local/src/influxdb-proxmox-token
echo "Token for Proxmox Metric Server in /usr/local/src/influxdb-proxmox-token"
echo "Use Port 8086 with HTTP option , instead of 8089 UDP"
cat /usr/local/src/influxdb-proxmox-token

/bin/cp  extra-files/grafana.ini /etc/grafana/

systemctl daemon-reload
systemctl stop grafana-server
systemctl start grafana-server

GPASSVPOP=`pwgen -c -1 8`
echo $GPASSVPOP > /usr/local/src/grafana-proxmox-pass
echo "Admin password in /usr/local/src/grafana-proxmox-pass"
cat /usr/local/src/grafana-proxmox-pass
grafana-cli admin reset-admin-password "$GPASSVPOP"

grafana-cli plugins install grafana-clock-panel 1>/dev/null 2>/dev/null
grafana-cli plugins install blackmirror1-singlestat-math-panel  1>/dev/null 2>/dev/null
grafana-cli plugins install alexanderzobnin-zabbix-appi   1>/dev/null 2>/dev/null
systemctl restart grafana-server
##
