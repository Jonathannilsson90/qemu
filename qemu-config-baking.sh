#!/bin/bash
ISO=$1
disk1="$PWD/ArchDisk1.qcow2" # 30 gb TODO: Fix sizes on row 16-17
disk2="$PWD/ArchDisk2.qcow2" # 30 gb TODO: Fix sizes on row 16-17

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

if [ ! -f "$HOME/arch_VARS" ]; then
  qemu-img create -f raw "$HOME/arch_VARS" 2M
fi

qemu-system-x86_64 -enable-kvm -cpu host \
  -drive file="$disk1",format=qcow2 \
  -drive file="$disk2",format=qcow2 \
  -cdrom "$ISO" \
  -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.ms.fd \
  -drive if=pflash,format=raw,file="$HOME"/arch_VARS \
  -m 2G \
  -boot d \
  -monitor stdio \
  -vnc :2 
