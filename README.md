# Docker SSH Port Forward Server

Dockerized SSH server that only allows TCP local and remote port forwarding. Image based on `python:3-alpine`. The [ssh-port-forward-client](https://github.com/David-Lor/Docker-SSH-Port-Forward-Client) image can be used for connecting to the server.

**This image is experimental and might have undesirable effects. Use it under your responsability!**

## Getting started

Assuming you have a public key file `sshkey.pub` within the current working directory:

```bash
docker run -d --name=ssh-portforwarding-server -p 2222:2222 -v "$(pwd)/sshkey.pub:/ssh_pubkey:ro" davidlor/ssh-port-forward-server
```

Keep in mind that this image:

- Runs the SSH server in port `2222` by default
- Expects a public ssh key in container path `/ssh_pubkey` by default
- Does not allow root login; must use the `ssh` user to connect
- Does not allow interactive/shell connections; must use the `-N` option on the ssh client

## Example

![Diagram](docs/diagram.png)

An example with all the steps involving a complete deployment of a SSH port forwarding server, client, upstream server and downstream client are available on the [test script](tools/test.sh).

You can connect locally to a deployed SSH server, without a Docker client container, with the following command:

```bash
ssh -N -L <local port>:<target host>:<target port> ssh@<ssh server host> -p 2222
```

## Configuration

Currently, the settings are provided through environment variables, which are the following:

- **SSH_PORT**: SSH server port (default: `2222`)
- **SSH_PUBKEYS_LOCATION**: path of the file where public keys are read from (default: `/ssh_pubkey`)

The files required for the server to work are:

- **SSH Public key/s**: multiple public keys can be provided (one per line), on a file mounted in `/ssh_pubkey` by default.

## TODO

- Allow providing ssh public key/s through environment variable
