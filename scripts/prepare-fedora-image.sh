#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/env.sh"

if [ ! -f "$FEDORA_CLOUD_IMAGE" ]; then
  wget https://download.fedoraproject.org/pub/fedora/linux/releases/$FEDORA_RELEASE/Cloud/x86_64/images/$FEDORA_CLOUD_IMAGE
fi

# Setup image
cp "$FEDORA_CLOUD_IMAGE" "$FEDORA_MY_IMAGE"
virt-customize -a "$FEDORA_MY_IMAGE" --ssh-inject "root:file:$SSH_PUB_KEY" --selinux-relabel
