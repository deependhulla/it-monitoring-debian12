#!/bin/bash

#export LANG=C
#export LC_CTYPE=en_US.UTF-8
#export LANGUAGE=en_US.UTF-8
#export LC_ALL=en_US.UTF-8

apt-get install -y apt-transport-https software-properties-common wget


mkdir -p /etc/apt/keyrings/ 2./dev/null
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

apt update 
apt -y install influxdb2 telegraf grafana
