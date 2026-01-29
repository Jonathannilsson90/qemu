#!/bin/bash
ISO=$1
DISK1="$PWD/ArchDISK1.qcow2" # 30 gb TODO: Fix sizes on row 16-17
DISK2="$PWD/ArchDISK2.qcow2" # 30 gb TODO: Fix sizes on row 16-17

case "$ISO" in
  *.iso) ;;
  *)
    echo "Please provide a valid .iso file" >&2
    exit 1
    ;;
esac

# Checking if there DISK1 and DISK2 is already on the system, if it already is it will skip this step.
if [ -n "$DISK1" ] && [ -n "$DISK2" ] && [ ! -e "$DISK1" ] && [ ! -e "$DISK2" ]; then
qemu-img create -f qcow2 "$DISK1" 3G
qemu-img create -f qcow2 "$DISK2" 3G
fi

#  echo "$DISK1"

qemu-system-x86_64 -enable-kvm -cpu host \
  -drive "$DISK1",format=qcow2 \
  -drive "$DISK2",format=qcow2 \
  -cdrom "$ISO" \
  -m 2G \
  -boot d \
  -vnc :1 -display none 
