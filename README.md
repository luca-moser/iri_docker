# IRI - Docker

This repository contains all config files to create an IRI instance via HTTPS using Caddy.

features:
* everything runs inside a docker container
* all configuration files are mapped to the host system
* `attachToTangle` requests are executed by a middleware with SSE PoW within Caddy (rev. proxy)
* Grafana dashboard with data from Chris H.'s iota prometheus exporter 

# instructions

prerequisites:
* your domain resolves to your machine
* Ubuntu 16.04
* your wan interface is eth0

clone the repository:
```
git clone github.com/luca-moser/iri_docker
```

execute the setup file and give it your domain as a parameter (i.e. iota-tangle.io):
```
mv iri_docker iri && cd iri
chmod +x setup.sh
./setup.sh {YOUR_DOMAIN_NAME}
```

the setup script automatically installs docker, docker-compose and boots up the service with the given docker-compose.yml file. 
The IRI API will be served via Caddy on port 14265. Caddy will handle automatic TLS certificate updates.

Following ports are auto. blocked from access on eth0:
* 14264 (port on which the actual IRI listens on, setup like this, so that Caddy proxies to the domain on that port, instead of localhost)
* 5556 (ZMQ port of IRI)
* 9090 (prometheus)
* 9100 (prometheus node exporter)
