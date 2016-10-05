#!/bin/bash
# Creates a DigitalOcean Server (droplet) based on the name of the current directory.
#    ENV: NAME - Use environment variable to name the server instead of the directory name.
# If the default docker-compose.yaml file exists, it will be built.
# Uses an optional "droplet-config.yml" file to setup droplet

MACHINE_NAME=${NAME:-`basename "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"`}

check_MACHINE_NAME() {
	if [ -z "$MACHINE_NAME" ]; then
	  echo 'machine name required'
	  exit 1
	fi
}

check_ACCESS_TOKEN() {
	if [ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]; then
	  echo 'DIGITALOCEAN_ACCESS_TOKEN required'
	  exit 1
	fi
}

create() {
	check_MACHINE_NAME

# docker-machine create --driver digitalocean --help
#
#Options:
#   
#   --digitalocean-access-token 										Digital Ocean access token [$DIGITALOCEAN_ACCESS_TOKEN]
#   --digitalocean-backups										enable backups for droplet [$DIGITALOCEAN_BACKUPS]
#   --digitalocean-image "ubuntu-15-10-x64"								Digital Ocean Image [$DIGITALOCEAN_IMAGE]
export DIGITALOCEAN_IMAGE="ubuntu-16-04-x64"
#   --digitalocean-ipv6											enable ipv6 for droplet [$DIGITALOCEAN_IPV6]
#   --digitalocean-private-networking									enable private networking for droplet [$DIGITALOCEAN_PRIVATE_NETWORKING]
#   --digitalocean-region "nyc3"										Digital Ocean region [$DIGITALOCEAN_REGION]
#   --digitalocean-size "512mb"										Digital Ocean size [$DIGITALOCEAN_SIZE]
export DIGITALOCEAN_SIZE="4gb"
#   --digitalocean-ssh-key-fingerprint 									SSH key fingerprint [$DIGITALOCEAN_SSH_KEY_FINGERPRINT]
#   --digitalocean-ssh-port "22"										SSH port [$DIGITALOCEAN_SSH_PORT]
#   --digitalocean-ssh-user "root"									SSH username [$DIGITALOCEAN_SSH_USER]
#   --digitalocean-userdata 										path to file with cloud-init user-data [$DIGITALOCEAN_USERDATA]
	if [ -f droplet-config.yml ]; then
		export DIGITALOCEAN_USERDATA="droplet-config.yml"
	fi
#   --driver, -d "none"											Driver to create machine with. [$MACHINE_DRIVER]
export MACHINE_DRIVER=digitalocean
#   --engine-env [--engine-env option --engine-env option]						Specify environment variables to set in the engine
#   --engine-insecure-registry [--engine-insecure-registry option --engine-insecure-registry option]	Specify insecure registries to allow with the created engine
#   --engine-install-url "https://get.docker.com"							Custom URL to use for engine installation [$MACHINE_DOCKER_INSTALL_URL]
#   --engine-label [--engine-label option --engine-label option]						Specify labels for the created engine
#   --engine-opt [--engine-opt option --engine-opt option]						Specify arbitrary flags to include with the created engine in the form flag=value
#   --engine-registry-mirror [--engine-registry-mirror option --engine-registry-mirror option]		Specify registry mirrors to use [$ENGINE_REGISTRY_MIRROR]
#   --engine-storage-driver 										Specify a storage driver to use with the engine
#   --swarm												Configure Machine with Swarm
#   --swarm-addr 											addr to advertise for Swarm (default: detect and use the machine IP)
#   --swarm-discovery 											Discovery service to use with Swarm
#   --swarm-experimental											Enable Swarm experimental features
#   --swarm-host "tcp://0.0.0.0:3376"									ip/socket to listen on for Swarm master
#   --swarm-image "swarm:latest"										Specify Docker image to use for Swarm [$MACHINE_SWARM_IMAGE]
#   --swarm-master											Configure Machine to be a Swarm master
#   --swarm-opt [--swarm-opt option --swarm-opt option]							Define arbitrary flags for swarm
#   --swarm-strategy "spread"										Define a default scheduling strategy for Swarm
#   --tls-san [--tls-san option --tls-san option]							Support extra SANs for TLS certs

	docker-machine create \
		$MACHINE_NAME
}

connect() {
	eval $(docker-machine env $MACHINE_NAME)
}

start() {
	check_MACHINE_NAME

	docker-machine start $MACHINE_NAME
}

stop() {
	check_MACHINE_NAME

	docker-machine stop $MACHINE_NAME
}

restart() {
	check_MACHINE_NAME

	stop && start
}

status() {
	check_MACHINE_NAME

	docker-machine status $MACHINE_NAME && docker-machine env $MACHINE_NAME
}

remove() {
	check_MACHINE_NAME

	docker-machine rm $MACHINE_NAME
}

build() {
	if [ -f docker-compose.yml ]; then
		connect && docker-compose build
	else
	  	echo 'docker compose YAML file not found: build not run'
	fi
}

up() {
	if [ ! -f docker-compose.yml ]; then
	  echo 'docker compose YAML file required'
	  exit 1
	fi
	connect && docker-compose up -d
}

check_ACCESS_TOKEN
case "$1" in
create)
    create
    ;;
connect)
    connect
    ;;
start)
    start
    ;;
stop)
    stop
    ;;
restart)
    restart
    ;;
status)
    status
    ;;
remove)
    remove
    ;;
build)
    build
    ;;
up)
    up
    ;;
*)
    if [ ! -z "$1" ]; then
        echo "Usage: $0 {create|connect|start|stop|restart|status|remove|build|up}"
        exit 1
    fi
    create && build
esac

exit $RETVAL

