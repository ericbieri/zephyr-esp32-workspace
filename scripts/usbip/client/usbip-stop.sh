#!/bin/bash

# Detach remote USB devices from devcontainer
/usr/sbin/usbip detach --port=$(/usr/sbin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')
/usr/sbin/usbip detach --port=$(/usr/sbin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')

# Wait for devices to be fully detached
sleep 1

# Remove device nodes created by mknod in the start script
# [ -e /dev/ttyACM0 ] && rm -f /dev/ttyACM0
# [ -e /dev/ttyACM1 ] && rm -f /dev/ttyACM1

# echo "Serial devices removed:"
# ls -l /dev/ttyACM* 2>/dev/null || echo "No ttyACM devices found"

# Remove device nodes created by mknod in the start script
[ -e /dev/ttyUSB0 ] && rm -f /dev/ttyUSB0
[ -e /dev/ttyUSB1 ] && rm -f /dev/ttyUSB1
[ -e /dev/ttyUSB2 ] && rm -f /dev/ttyUSB2

# echo "Serial devices removed:"
ls -l /dev/ttyUSB* 2>/dev/null || echo "No ttyUSB devices found"