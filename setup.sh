#!/bin/bash
DOMAIN=$1
echo "starting iri setup:"

echo "will create iri service under ${DOMAIN}:14265 and Grafana dashboard under monitor.${DOMAIN}:3000"

# install required dependencies
apt update && apt install -y git apt-transport-https ca-certificates curl jq software-properties-common

# install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs)stable"
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

# block ports from the outside
echo "blocking iri, prometheus and prom-node-exporter ports from outside connections:"
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
./service start

echo "iri, caddy, prometheus and grafana are now running"
echo "iri API port is available under https://${DOMAIN}:14265"
echo "Grafana dashboard is available under https://monitor.${DOMAIN}:3000"