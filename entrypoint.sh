#!/bin/sh

set -ex

cd /etc/ssh
ssh-keygen -A

echo "$(cat /ssh_pubkey)" > /home/ssh/.ssh/authorized_keys

exec /usr/sbin/sshd -D -e $@
