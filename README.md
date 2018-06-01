# IRI - Docker

This repository contains all config files to create an IRI instance via HTTPS using Caddy.

Features:
* Everything runs inside a docker container
* All configuration files are mapped to the host system
* `attachToTangle` requests are executed by a middleware with SSE PoW
* Grafana dashboard with data from Chris H.'s iota prometheus exporter 

# Installation

Prerequisites:
* Your domain resolves to your machine:
  The `setup.sh` script will setup the services to work under {YOUR_DOMAIN_NAME} and monitor.{YOUR_DOMAIN_NAME}, so make sure both
  domains resolve to your IP address. 
* Ubuntu 16.04 (as of writing this guide, the official Docker repository wasn't updated for Ubuntu 18.04)
* Your WAN interface is eth0 (some iptable rules will be set to block certain INPUT traffic on specific ports)

Clone the repository:
```
git clone https://github.com/luca-moser/iri_docker.git
```

Execute the setup file and give it your domain as a parameter (i.e. iota-tangle.io):
```
mv iri_docker iri && cd iri
chmod +x setup.sh
./setup.sh {YOUR_DOMAIN_NAME}
```

The setup script automatically installs docker, docker-compose and boots up the service with the given docker-compose.yml file. 
The IRI API will be served via Caddy on https://{YOUR_DOMAIN_NAME}:14265. Caddy will handle automatic TLS certificate updates and execute `attachToTangle` in
it's `attach` middleware for faster PoW times. Grafana will be available under https://monitor.{YOUR_DOMAIN_NAME}:3000.

**Make sure to change the password of the Grafana dashboard admin user!**

However, we are not done yet:

# After installation
First, stop all the services with `./service.sh stop`.

While IRI was already running, it wasn't usable yet. You now have to first download a fresh snapshot of the database and add it under
`./volumes/iota/mainnetdb`. I recommend you download the snapshot via `wget http://db.iota.partners/IOTA.partners-mainnetdb.tar.gz`.
Then, make sure to hop onto the Discord server and go to the #nodesharing channel to find neighbours for your node.
I don't recommend to use Nelson as its implications on the network are not yet fully understood. **Add max. 4 neighbours to your node.**

# Meta

Following ports are auto. blocked from access on eth0 via `iptables` (check the `setup.sh` file):
* 14264 (port on which the actual IRI listens on, setup like this, so that Caddy proxies to the domain on that port, instead of localhost)
* 5556 (ZMQ port of IRI)
* 9090 (prometheus)
* 9100 (prometheus node exporter)