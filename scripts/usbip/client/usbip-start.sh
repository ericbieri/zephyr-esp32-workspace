#!/bin/bash

# Find Docker host IP
# - Inside Container: ip route show default | awk '{print $3}'
# - On Host: ip addr show docker0
# 
# Plain Docker -> 172.17.0.1
# Docker Desktop -> host.docker.internal 
# RPI -> 192.168.1.250
server=192.168.1.250

# ESP32 Feather / ESPProg
usb1='10c4:ea60' # Feather ESP32, Silicon Labs CP210x UART Bridge
usb2='0403:6010' # ESPProg, FT2232C/D/H Dual UART/FIFO IC

# ESP32-S3 DevKitC USBs
# usb1='303a:1001' # Espressif USB JTAG/serial debug unit
# usb2='1a86:55d3' # QinHeng Electronics USB Single Serial

# Attach remote USB devices to devcontainer
/usr/sbin/usbip attach -r $server -b $(/usr/sbin/usbip list -r $server | grep $usb1 | cut -d':' -f1 | xargs)
/usr/sbin/usbip attach -r $server -b $(/usr/sbin/usbip list -r $server | grep $usb2 | cut -d':' -f1 | xargs)

# Create device nodes (needed in devcontainer as /dev is isolated)
# Wait a moment for kernel to register devices
sleep 2

# Create ACM device nodes if they don't exist
# [ ! -e /dev/ttyACM0 ] && mknod /dev/ttyACM0 c 166 0
# [ ! -e /dev/ttyACM1 ] && mknod /dev/ttyACM1 c 166 1

# # Set permissions for serial access
# chmod 666 /dev/ttyACM0 2>/dev/null

# echo "Serial devices created:"
# ls -l /dev/ttyACM*

# Create USBx device nodes if they don't exist
[ ! -e /dev/ttyUSB0 ] && mknod /dev/ttyUSB0 c 188 0
[ ! -e /dev/ttyUSB1 ] && mknod /dev/ttyUSB1 c 188 1
[ ! -e /dev/ttyUSB2 ] && mknod /dev/ttyUSB2 c 188 2

# Set permissions for serial access
# chmod 666 /dev/ttyUSB0 2>/dev/null

# echo "Serial devices created:"
# ls -l /dev/ttyUSB*
