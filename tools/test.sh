#!/bin/bash

SSH_SERVER_IMAGE=${SSH_SERVER_IMAGE:="davidlor/ssh-port-forward-server:latest"}
SSH_CLIENT_IMAGE=${SSH_CLIENT_IMAGE:="davidlor/ssh-port-forward-client:latest"}
SSH_KEYS_LOCATION="/tmp/ssh-port-forward-test-keys"  # Path MUST NOT EXIST (will be removed); without ending /

NETWORK_A="ssh-portforwarding-network-a"
NETWORK_B="ssh-portforwarding-network-b"
NETWORK_TRUNK="ssh-portforwarding-network-trunk"

CONTAINER_SSH_SERVER="ssh-portforwarding-A-server"
CONTAINER_SSH_CLIENT="ssh-portforwarding-B-client"
CONTAINER_UPSTREAM_SERVER="ssh-portforwarding-A-nginx"

set -x

# Create public & private keys
mkdir ${SSH_KEYS_LOCATION} || { echo "SSH Keys location path must not exist!"; exit 1; }
ssh-keygen -f "$SSH_KEYS_LOCATION/sshkey" -q -N ""

# Create networks
docker network create ${NETWORK_A}
docker network create ${NETWORK_B}
docker network create ${NETWORK_TRUNK}

# Create SSH Server container
docker run -d --name=${CONTAINER_SSH_SERVER} \
    --network=${NETWORK_TRUNK} \
    -v "$SSH_KEYS_LOCATION/sshkey.pub:/ssh_pubkey:ro" \
    ${SSH_SERVER_IMAGE}
docker network connect ${NETWORK_A} ${CONTAINER_SSH_SERVER}

# Create Nginx Server container (Upstream server, the server that we will try to connect to through forwarded port)
docker run -d --name=${CONTAINER_UPSTREAM_SERVER} \
    --network=${NETWORK_A} \
    nginxdemos/hello

# Create SSH Client container
docker run -d --name=${CONTAINER_SSH_CLIENT} \
    --network=${NETWORK_TRUNK} \
    -e MAPPINGS="80:$CONTAINER_UPSTREAM_SERVER:80" \
    -e "SSH_HOST=$CONTAINER_SSH_SERVER" \
    -e "SSH_PORT=2222" \
    -e "SSH_USER=ssh" \
    -v "$SSH_KEYS_LOCATION/sshkey:/ssh_key:ro" \
    ${SSH_CLIENT_IMAGE}
docker network connect ${NETWORK_B} ${CONTAINER_SSH_CLIENT}

# Run HTTP Client container
docker run --rm --network=${NETWORK_B} curlimages/curl \
    curl "http://$CONTAINER_SSH_CLIENT:80"
# If everything worked, you should be able to see some HTML

# Press enter to continue if HTTP Client container failed execution (for manually reviewing containers before teardown)
if [ $? -ne 0 ]
then
  echo "Press Enter to continue with teardown"
  read -r
fi

# Teardown all
docker stop ${CONTAINER_UPSTREAM_SERVER} ${CONTAINER_SSH_CLIENT} ${CONTAINER_SSH_SERVER}
docker rm ${CONTAINER_UPSTREAM_SERVER} ${CONTAINER_SSH_CLIENT} ${CONTAINER_SSH_SERVER}
docker network rm ${NETWORK_A} ${NETWORK_B} ${NETWORK_TRUNK}
rm -rf ${SSH_KEYS_LOCATION}
