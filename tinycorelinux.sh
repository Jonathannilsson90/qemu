#!/bin/bash
qemu-system-x86_64 -enable-kvm -cpu host \
  -drive file=/home/jonnil/tiny.qcow2,format=qcow2 \
  -cdrom ~/Downloads/TinyCore-current.iso \
  -m 2G \
  -boot d \
  -vnc :1 -display none
