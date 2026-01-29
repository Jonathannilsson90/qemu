#!/bin/bash
ISO=$1

VM_DIR="$HOME/VM/arch"

READONLY_CODE="/usr/share/OVMF/OVMF_CODE_4M.fd"
VARS_TEMPLATE="/usr/share/OVMF/OVMF_VARS_4M.fd"

DISK1="$VM_DIR/disk1.qcow2"
DISK2="$VM_DIR/disk2.qcow2" 

VARS_FILE="$VM_DIR/arch_VARS_4M.ms.qcow2"

case "$ISO" in
  *.iso) ;;
  *)
    echo "Please provide a valid .iso file" >&2
    exit 1
    ;;
esac

# Checking if there DISK1 and DISK2 is already on the system, if it already is it will skip this step.

 [ -e "$DISK1" ] || qemu-img create -f qcow2 "$DISK1" 10G #TODO : FIX SIZES ACCORDING TO THE HANDIN 30G
 [ -e "$DISK2" ] || qemu-img create -f qcow2 "$DISK2" 10G #TODO : FIX SIZES ACCORDING TO THE HANDIN 30G

mkdir -p "$VM_DIR"
mkdir -p "$VM_DIR/pid"

if [ ! -f "$VARS_FILE" ]; then
  if [ -f "$VARS_TEMPLATE" ]; then
    qemu-img convert -f raw -O qcow2 \
    "$VARS_TEMPLATE" "$VARS_FILE"
  else 
    echo "Could not find OMVF_VARS.4M.fd on this system" >&2
    exit 1
  fi
fi

qemu-system-x86_64 -enable-kvm -cpu host \
  -drive file="$DISK1",format=qcow2 \
  -drive file="$DISK2",format=qcow2 \
  -cdrom "$ISO" \
  -drive if=pflash,format=raw,readonly=on,file=$READONLY_CODE \
  -drive if=pflash,format=qcow2,file="$VARS_FILE" \
  -m 2G \
  -boot d \
  -monitor stdio \
  -machine q35 \
  -pidfile "$VM_DIR/pid/qemu-pid" \
  -monitor unix:"$VM_DIR/qemu-mon.sock",server,nowait \
	-nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22 \
  -vnc :2 

# Restart
# sudo rm -rf $"VM_DIR"