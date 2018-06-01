#!/bin/bash
DOMAIN=$1
echo "starting iri setup:"

echo "will create iri service under ${DOMAIN}:14265 and Grafana dashboard under monitor.${DOMAIN}:3000"

# install required dependencies
apt update && apt install -y git apt-transport-https ca-certificates curl jq software-properties-common

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update && apt install -y docker-ce
echo "verifying docker installation:"
docker --version

# intall docker-compose
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "verifying docker compose installation:"
docker-compose --version

# make shell scripts executable
chmod +x *.sh
chmod -r 777 ./volumes/prometheus/data

# block ports from the outside
echo "blocking IRI, Prometheus and Prom-Node-Exporter ports from outside connections:"
# iri
iptables -A INPUT -p tcp -i eth0 --dport 14264 -j DROP
iptables -A INPUT -p udp -i eth0 --dport 14264 -j DROP
# iri ZMQ
iptables -A INPUT -p tcp -i eth0 --dport 5556 -j DROP
iptables -A INPUT -p udp -i eth0 --dport 5556 -j DROP
# prometheus
iptables -A INPUT -p tcp -i eth0 --dport 9090 -j DROP
iptables -A INPUT -p udp -i eth0 --dport 9090 -j DROP
# prometheus node exporter
iptables -A INPUT -p tcp -i eth0 --dport 9100 -j DROP
iptables -A INPUT -p udp -i eth0 --dport 9100 -j DROP

# replace Caddyfile domains
sed -i 's/{IRI_URL}/'$DOMAIN'/g' ./volumes/caddy/Caddyfile

# boot up service
echo "booting up service:"
./service.sh start

sleep 10

GRAFANA_URL="http://admin:admin@127.0.0.1:3000"

# add datasource to Grafana
curl -s -f -S --request POST $GRAFANA_URL/api/datasources -H "Content-Type: application/json" --data-binary @grafana_datasource.json

# add dashboard to Grafana
curl -s -f -S --request POST $GRAFANA_URL/api/dashboards/db -H "Content-Type: application/json" --data-binary @chris_h_iri_dashboard.json

echo ""
echo ""
echo "IRI, Caddy, Prometheus and Grafana are now running"
echo "IRI API port is available under https://${DOMAIN}:14265"
echo "Grafana is available under https://monitor.${DOMAIN}:3000"
echo "Make sure to change the admin user's password for Grafana!"
echo "You will start to see metrics once you've added at least one IRI neighbour."
echo ""
echo "Start to add neighbours by using add.sh AND modifying ./volumes/iri/iota.ini"
echo "Thanks for installing IRI!"