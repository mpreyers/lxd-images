#!/usr/bin/env bash
set -e

ROOT_MOUNT="$(mount | fgrep 'on / type')"

# Setup btrfs if supported
if echo "$ROOT_MOUNT" | fgrep 'type btrfs'; then
  sed -i 's/^driver.*/driver = "btrfs"/' /etc/containers/storage.conf
fi

# Add pseudo root device
ROOT_DEVICE="$(echo "$ROOT_DEDICE" | awk '{print $1}')"
if [[ ! -b "$ROOT_DEVICE" ]]; then
  if [[ ! -d /var/lib/k3ckstart ]]; then
    mkdir -p /var/lib/k3ckstart
  fi
  if [[ ! -f /var/lib/k3ckstart/pseudo.img ]]; then
    dd if=/dev/zero of=/var/lib/k3ckstart/pseudo.img bs=100M count=10
    mkfs.btrfs -f /var/lib/k3ckstart/pseudo.img
  fi
  mknod "$ROOT_DEVICE" b 7 100
  losetup "$ROOT_DEVICE" /var/lib/k3ckstart/pseudo.img
fi
