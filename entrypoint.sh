#!/bin/sh

set -ex

python -u /setup.py
exec /usr/sbin/sshd -D -e $@
