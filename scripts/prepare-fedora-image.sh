#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. "$SCRIPT_DIR/env.sh"

IMAGE_SIZE=${1:-10G}

FEDORA_RELEASE=35
CLOUD_IMAGE="Fedora-Cloud-Base-${FEDORA_RELEASE}-1.2.x86_64.qcow2"
BASE_FEDORA_IMAGE=my-fedora-${FEDORA_RELEASE}.qcow2

if [ ! -f "$CLOUD_IMAGE" ]; then
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/$FEDORA_RELEASE/Cloud/x86_64/images/$CLOUD_IMAGE
fi

qemu-img create -f qcow2 "$BASE_FEDORA_IMAGE" "$IMAGE_SIZE"
virt-resize --format=qcow2 --expand /dev/sda5 "$CLOUD_IMAGE" "$BASE_FEDORA_IMAGE"

virt-filesystems --long --parts --blkdevs -h --format=qcow2 -a "$BASE_FEDORA_IMAGE"
  
virt-customize -a "$BASE_FEDORA_IMAGE" --ssh-inject "root:file:$SSH_PUB_KEY" --selinux-relabel
