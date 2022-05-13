#!/usr/bin/env bash
set -eu

APPLIANCE_VERSION="1.46.0"
APPLIANCE_ARCHIVE="appliance-${APPLIANCE_VERSION}.tar.xz"

if [ ! -f "appliance/kernel" ]; then
  if [ ! -f "$APPLIANCE_ARCHIVE" ]; then
    wget "https://download.libguestfs.org/binaries/appliance/$APPLIANCE_ARCHIVE"
  fi
  tar xvJf "$APPLIANCE_ARCHIVE"
fi

export LIBGUESTFS_PATH="$(pwd)/appliance"
