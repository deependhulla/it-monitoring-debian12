GPASSVPOP=`pwgen -c -1 8`
echo $GPASSVPOP > /usr/local/src/grafana-proxmox-pass
echo "Admin password in /usr/local/src/grafana-proxmox-pass"
cat /usr/local/src/grafana-proxmox-pass
grafana-cli admin reset-admin-password "$GPASSVPOP"

systemctl restart grafana-server
