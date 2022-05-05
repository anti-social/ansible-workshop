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
