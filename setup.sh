#!/bin/bash
DOMAIN=$1

Color_Off='\033[0m'
Red='\033[0;31m'
White='\033[0;37m'
Cyan='\033[0;36m'
Yellow='\033[0;33m'

if [ -z "$1" ]
then
	echo -e "${Red}please supply the domain name as the first argument."
	exit 1
fi

echo -e "${White}starting iri setup:"
echo -e "will create iri service under ${DOMAIN}:14265 and Grafana dashboard under monitor.${DOMAIN}:8080"
sleep 3
echo -e ""

# install required dependencies
apt update && apt install -y git apt-transport-https ca-certificates curl jq software-properties-common

# install docker
echo -e "INSTALLING DOCKER:${Color_Off}"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update && apt install -y docker-ce
echo -e "verifying docker installation:"
docker --version

# intall docker-compose
echo -e "${white}INSTALLING DOCKER COMPOSE:${Color_Off}"
curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo -e "${white}verifying docker compose installation:{Color_Off}"
docker-compose --version

# make shell scripts executable
chmod +x *.sh
chmod 777 ./volumes/prometheus/data

# block ports from the outside
echo -e "${White}Blocking IRI, Prometheus and Prom-Node-Exporter ports from outside connections:"
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
echo -e "Booting up service:${Color_Off}"
./service.sh start

echo -e "${White}Cooldown 10 seconds....${Color_Off}"
sleep 10

GRAFANA_URL="http://admin:admin@127.0.0.1:3000"

# add datasource to Grafana
echo -e "${White}Supplying Grafana with datasource and dashboard:${Color_Off}"
curl -s -f -S --request POST $GRAFANA_URL/api/datasources -H "Content-Type: application/json" --data-binary @grafana_datasource.json

# add dashboard to Grafana
curl -s -f -S --request POST $GRAFANA_URL/api/dashboards/db -H "Content-Type: application/json" --data-binary @chris_h_iri_dashboard.json

echo -e ""
echo -e "${White}"
echo "IRI, Caddy, Prometheus and Grafana are now running"
echo -e "IRI API port is available under ${Cyan}https://${DOMAIN}:14265${White}"
echo -e "Grafana is available under ${Cyan}https://monitor.${DOMAIN}:8080${White}"
echo -e "${Yellow}!Make sure to change the admin user's password for Grafana!"
echo -e "!You will start to see metrics once you've added at least one IRI neighbour!${White}"
echo -e ""
echo -e "Start to add neighbours by using add.sh AND modifying ./volumes/iri/iota.ini"
echo -e "Thanks for installing IRI!"