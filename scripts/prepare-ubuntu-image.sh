#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

. "$SCRIPT_DIR/env.sh"

IMAGE_SIZE=${1:-10G}
UBUNTU_DISTRO="jammy"
CLOUD_IMAGE="${UBUNTU_DISTRO}-server-cloudimg-amd64.img"

if [ ! -f "$CLOUD_IMAGE" ]; then
  wget https://cloud-images.ubuntu.com/$UBUNTU_DISTRO/current/$CLOUD_IMAGE
fi
  
BASE_UBUNTU_IMAGE_NAME=my-ubuntu-${UBUNTU_DISTRO}
BASE_UBUNTU_IMAGE=$BASE_UBUNTU_IMAGE_NAME.qcow2
BASE_UBUNTU_IMAGE_RAW=$BASE_UBUNTU_IMAGE_NAME.raw

# Resize image
qemu-img convert -f qcow2 -O raw "$CLOUD_IMAGE" "$BASE_UBUNTU_IMAGE_RAW"
qemu-img resize -f raw "$BASE_UBUNTU_IMAGE_RAW" $IMAGE_SIZE
growpart "$BASE_UBUNTU_IMAGE_RAW" 1
qemu-img convert -f raw -O qcow2 "$BASE_UBUNTU_IMAGE_RAW" "$BASE_UBUNTU_IMAGE"
rm -f "$BASE_UBUNTU_IMAGE_RAW"

virt-filesystems --long --parts --blkdevs -h --format=qcow2 -a "$BASE_UBUNTU_IMAGE"

# Setup image
virt-customize -a $BASE_UBUNTU_IMAGE --ssh-inject "root:file:$SSH_PUB_KEY"
guestfish -i -a $BASE_UBUNTU_IMAGE \
  copy-in "$SCRIPT_DIR/99-config.yaml" /etc/netplan/ : \
  chown 0 0 /etc/netplan/99-config.yaml : \
  copy-in "$SCRIPT_DIR/regenerate-ssh-host-keys.service" /etc/systemd/system/ : \
  chown 0 0 /etc/systemd/system/regenerate-ssh-host-keys.service : \
  ln-sf /etc/systemd/system/regenerate-ssh-host-keys.service /etc/systemd/system/multi-user.target.wants/regenerate-ssh-host-keys.service : \
  copy-in "$SCRIPT_DIR/resize-rootfs.service" /etc/systemd/system/ : \
  chown 0 0 /etc/systemd/system/resize-rootfs.service : \
  ln-sf /etc/systemd/system/resize-rootfs.service /etc/systemd/system/multi-user.target.wants/resize-rootfs.service
