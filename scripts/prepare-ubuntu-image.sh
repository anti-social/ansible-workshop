#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/env.sh"
. "$SCRIPT_DIR/setup-appliance.sh"

if [ ! -f "$UBUNTU_CLOUD_IMAGE" ]; then
  wget https://cloud-images.ubuntu.com/$UBUNTU_DISTRO/current/$CLOUD_IMAGE
fi

cp "$UBUNTU_CLOUD_IMAGE" "$UBUNTU_MY_IMAGE"

# Setup image
FILES_DIR="$SCRIPT_DIR/ubuntu"
virt-customize -a "$UBUNTU_MY_IMAGE" --ssh-inject "root:file:$SSH_PUB_KEY"
guestfish -i -a "$UBUNTU_MY_IMAGE" \
  copy-in "$FILES_DIR/99-config.yaml" /etc/netplan/ : \
  chown 0 0 /etc/netplan/99-config.yaml : \
  copy-in "$FILES_DIR/regenerate-ssh-host-keys.service" /etc/systemd/system/ : \
  chown 0 0 /etc/systemd/system/regenerate-ssh-host-keys.service : \
  ln-sf /etc/systemd/system/regenerate-ssh-host-keys.service /etc/systemd/system/multi-user.target.wants/regenerate-ssh-host-keys.service : \
  copy-in "$FILES_DIR/resize-rootfs.service" /etc/systemd/system/ : \
  chown 0 0 /etc/systemd/system/resize-rootfs.service : \
  ln-sf /etc/systemd/system/resize-rootfs.service /etc/systemd/system/multi-user.target.wants/resize-rootfs.service : \
  copy-in "$FILES_DIR/policy-rc.d" /usr/sbin/ : \
  chown 0 0 /usr/sbin/policy-rc.d : \
  chmod 0755 /usr/sbin/policy-rc.d
