#!/usr/bin/env bash
set -eux

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
. "$SCRIPT_DIR/env.sh"

OS_TYPE=$1
VM_NAME=$2
IMAGE_SIZE=${3:-10G}

IMAGE=$VM_NAME.qcow2
if [ "$OS_TYPE" == "fedora" ]; then
  OS_VARIANT=$FEDORA_VM_VARIANT
  BASE_IMAGE=$FEDORA_MY_IMAGE
elif [ "$OS_TYPE" == "ubuntu" ]; then
  OS_VARIANT=$UBUNTU_VM_VARIANT
  BASE_IMAGE=$UBUNTU_MY_IMAGE
fi

# Resize image
if [ "$OS_TYPE" == "fedora" ]; then
  qemu-img create -f qcow2 "$IMAGE" "$IMAGE_SIZE"
  virt-resize --format=qcow2 --expand /dev/sda5 "$BASE_IMAGE" "$IMAGE"
elif [ "$OS_TYPE" == "ubuntu" ]; then
  # TODO: Find out nicer way to resize ubuntu image
  qemu-img convert -f qcow2 -O raw "$BASE_IMAGE" "${IMAGE}.raw"
  qemu-img resize -f raw "${IMAGE}.raw" $IMAGE_SIZE
  growpart "${IMAGE}.raw" 1
  qemu-img convert -f raw -O qcow2 "${IMAGE}.raw" "$IMAGE"
  rm -f "${IMAGE}.raw"
fi

# Show filesystems
# virt-filesystems --long --parts --blkdevs -h --format=qcow2 -a "$IMAGE"

# Setup
virt-customize -a "$IMAGE" --hostname $VM_NAME

# Run VM
virt-install --name $VM_NAME --os-variant $OS_VARIANT --import --ram 1024 --vcpus 2 --disk $IMAGE -w bridge=virbr0 --print-xml > .$VM_NAME.xml
sudo virsh create .$VM_NAME.xml
rm .$VM_NAME.xml
