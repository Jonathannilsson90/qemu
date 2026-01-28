#!/bin/bash
ISO=$1
disk1="$PWD/ArchDisk1.qcow2" # 30 gb
disk2="$PWD/ArchDisk2.qcow2" # 30 gb

case "$ISO" in
  *.iso) ;;
  *)
    echo "Please provide a valid .iso file" >&2
    exit 1
    ;;
esac

# Checking if there disk1 and disk2 is already on the system, if it already is it will skip this step.
if [ -n "$disk1" ] && [ -n "$disk2" ] && [ ! -e "$disk1" ] && [ ! -e "$disk2" ]; then
qemu-img create -f qcow2 "$disk1" 3G
qemu-img create -f qcow2 "$disk2" 3G
fi

#  echo "$disk1"

qemu-system-x86_64 -enable-kvm -cpu host \
  -drive "$disk1",format=qcow2 \
  -drive "$disk2",format=qcow2 \
  -cdrom "$ISO" \
  -m 2G \
  -boot d \
  -vnc :1 -display none 
