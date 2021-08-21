#!/usr/bin/env python

import os
import sys
import subprocess
from typing import Optional


class SettingsConst:
    ssh_port = "SSH_PORT"
    ssh_pubkeys_location = "SSH_PUBKEYS_LOCATION"
    ssh_user = "SSH_USER"


SSHD_CONFIG_PATH = "/etc/ssh/sshd_config"
SSHD_CONFIG_TEMPLATE = f"""
Port {{{SettingsConst.ssh_port}}}
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes

AllowUsers ssh
AllowGroups ssh

Match User ssh
    AllowTcpForwarding yes
    GatewayPorts yes
    X11Forwarding no
    PermitTTY no
"""


class Settings:
    def __init__(self):
        self.port = int(self.getenv(SettingsConst.ssh_port))
        self.pubkeys_location = self.getenv(SettingsConst.ssh_pubkeys_location)
        self.user = self.getenv(SettingsConst.ssh_user)

    @staticmethod
    def getenv(key, default_value=None, allow_empty=False) -> Optional[str]:
        value = os.getenv(key, default_value)
        if value is None or (value == "" and not allow_empty):
            print(f"The environment variable {key} is not set!")
            sys.exit(1)
        return value


def _generate_host_keys():
    """Generate the server SSH host keys"""
    subprocess.call(["ssh-keygen", "-A"], cwd="/etc/ssh")


def _write_public_keys(settings: Settings):
    """Copy the public keys from the SSH PubKeys file into the authorized_keys file of the current user."""
    with open(settings.pubkeys_location, "r") as pubkeys_read_file:
        pubkeys_content = pubkeys_read_file.read().strip()

    with open(f"/home/{settings.user}/.ssh/authorized_keys", "w") as pubkeys_write_file:
        pubkeys_write_file.write(pubkeys_content)
        print(f"{len(pubkeys_content.splitlines())} public keys loaded")


def _format_sshd_config(settings: Settings) -> str:
    """Return the content of the sshd_config file, based on the settings."""
    format_map = {
        SettingsConst.ssh_port: settings.port
    }
    return SSHD_CONFIG_TEMPLATE.format_map(format_map).strip()


def _write_sshd_config(content: str):
    with open(SSHD_CONFIG_PATH, "w") as file:
        file.write(content)


def main():
    settings = Settings()

    _generate_host_keys()
    _write_public_keys(settings)

    sshd_config_content = _format_sshd_config(settings)
    _write_sshd_config(sshd_config_content)


if __name__ == "__main__":
    main()
