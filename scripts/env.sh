#!/usr/bin/env bash
set -eux

if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
  SSH_PUB_KEY="$HOME/.ssh/id_ed25519.pub"
elif [ -f "$HOME/.ssh/id_rsa.pub" ]; then
  SSH_PUB_KEY="$HOME/.ssh/id_rsa.pub"
else
  echo "Not found ssh public key"
  exit 1
fi

FEDORA_RELEASE=${FEDORA_RELEASE:-35}
FEDORA_CLOUD_IMAGE="Fedora-Cloud-Base-${FEDORA_RELEASE}-1.2.x86_64.qcow2"
FEDORA_MY_IMAGE=my-fedora-${FEDORA_RELEASE}.qcow2
FEDORA_VM_VARIANT=fedora35

UBUNTU_CODENAME="jammy"
UBUNTU_CLOUD_IMAGE="${UBUNTU_CODENAME}-server-cloudimg-amd64.img"
UBUNTU_MY_IMAGE=my-ubuntu-${UBUNTU_CODENAME}.qcow2
UBUNTU_VM_VARIANT=ubuntu20.04
