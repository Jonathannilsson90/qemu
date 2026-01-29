#!/bin/bash
ISO=$1
disk1="$PWD/ArchDisk1.qcow2" # 30 gb TODO: Fix sizes on row 16-17
disk2="$PWD/ArchDisk2.qcow2" # 30 gb TODO: Fix sizes on row 16-17

READONLY_CODE="/usr/share/OVMF/OVMF_CODE_4M.ms.fd"
VARS_TEMPLATE="/usr/share/OVMF/OVMF_VARS_4M.fd"

VARS_DIR="$HOME/arch"
VARS_FILE="$VARS_DIR/arch_VARS_4M.fd"

case "$ISO" in
  *.iso) ;;
  *)
    echo "Please provide a valid .iso file" >&2
    exit 1
    ;;
esac

# Checking if there disk1 and disk2 is already on the system, if it already is it will skip this step.

 [ -e "$disk1" ] || qemu-img create -f qcow2 "$disk1" 3G
 [ -e "$disk2" ] || qemu-img create -f qcow2 "$disk2" 3G


mkdir -p "$VARS_DIR"


if [ ! -f "$VARS_FILE" ]; then
  if [ -f "$VARS_TEMPLATE" ]; then
    cp "$VARS_TEMPLATE" "$VARS_FILE"
  else 
  echo "Could not find OMVF_VARS.4M.fd on this system" >&2
  exit 1
  fi
fi

qemu-system-x86_64 -enable-kvm -cpu host \
  -drive file="$disk1",format=qcow2 \
  -drive file="$disk2",format=qcow2 \
  -cdrom "$ISO" \
  -drive if=pflash,format=raw,readonly=on,file=$READONLY_CODE \
  -drive if=pflash,format=raw,file="$VARS_FILE" \
  -m 2G \
  -boot d \
  -monitor stdio \
  -machine q35 \
  -vnc :1 
