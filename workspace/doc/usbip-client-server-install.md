# USB over IP
### Links
* [Youtube - How To Share USB Devices Over IP Using A Raspberry Pi](https://www.youtube.com/watch?v=xKVrt0_iTzI)
* [Github - usbip-utils](https://github.com/lucianm/usbip-utils)
* [Github - usbip-win](https://github.com/dorssel/usbipd-win)
* [Github - pyusbip](https://github.com/jwise/pyusbip)
* [Github - usbip (OSX)](https://github.com/jiegec/usbip)
* [ubuntuusers - USBIP](https://wiki.ubuntuusers.de/USBIP/)
* [Sourceforge - usbip - deprecated](https://usbip.sourceforge.net/)
* [Docker - doc - USB/IP with Docker Desktop](https://docs.docker.com/desktop/features/usbip/)
* [Golioth - blog - USB with Docker on Windows and macOS Now Possible](https://blog.golioth.io/usb-docker-windows-macos/)

##  USBIP Server on Ubuntu
The usbip package isn't available in the standard Ubuntu repos. 
* sudo apt update
* __Install linux-tools__:  
	* debian: sudo apt install usbip
	* ubuntu: sudo apt install linux-tools-generic
* __Load kernel modules__
	* sudo modprobe usbip_host
	* echo 'usbip_host' >> /etc/modules // TODO /etc/modules is obsolete, replacement?
	* 
* __List devices__ sudo usbip list -local

// TODO HERE
* Server
	* start/stop skript
	* chmod +x ./usbip_start.sh

service

modprobe vhci_hcd" loads the kernel module that implements the USB/IP client-side virtual host controller (VHCI). It creates a virtual USB host so remote USB devices exported over USB/IP can be attached locally.

* Client
	* apt install usbip hwdata usbutils
	* modprobe vhci_hcd -fails!!

// HERE
// TODO Install usbip on RPI
* RPI USBIP Server
* Install USBIP Server mit ESP32S3 on RPI -> https://www.youtube.com/watch?v=xKVrt0_iTzI
* Try to connect from VM / OSX

## USBIP Server on Raspberry PI
### Set static IP:
```
sudo nmcli con modify "netplan-wlan0-privat55" \
ipv4.method manual \
ipv4.addresses 192.168.1.250/24 \
ipv4.gateway 192.168.1.1 \
ipv4.dns "192.168.1.1 8.8.8.8 8.8.4.4"*
```

### Install usbip:  
* su - // switch to root
* apt update
* apt install usbip

### Load kernel module usbip_host
	* modeprobe usbip_host
	* echo 'usbip_host' >> /etc/modules

### udev
platformio

### Create usbip_start.sh script
* usbip list -l
* nano /usr/sbin/usbip_start.sh
```
#!/bin/bash

# ESP32-S3 DevKitC USBs <VendorID>:<DeviceID>
usb1='303a:1001'
usb2='1a86:55d3'

sudo /usr/sbin/usbip bind --$(/usr/sbin/usbip list -p -l | grep '#usbid='$usb1'#' | cut -d'#' -f1)
sudo /usr/sbin/usbip bind --$(/usr/sbin/usbip list -p -l | grep '#usbid='$usb2'#' | cut -d'#' -f1)
```
* chmod +x /usr/sbin/usbip_start.sh

### Create usbip_stop.sh script
* nano /usr/sbin/usbip_stop.sh
```
#!/bin/bash

# ESP32-S3 DevKitC USBs <VendorID>:<DeviceID>
usb1='303a:1001'
usb2='1a86:55d3'

sudo /usr/sbin/usbip unbind --$(/usr/sbin/usbip list -p -l | grep '#usbid='$usb1'#' | cut -d'#' -f1)
sudo /usr/sbin/usbip unbind --$(/usr/sbin/usbip list -p -l | grep '#usbid='$usb2'#' | cut -d'#' -f1)
sudo killall usbipd
```
* chmod +x /usr/sbin/usbip_stop.sh

### Create usbipd.service
* nano /lib/systemd/system/usbipd.service

```
[Unit]
Description=usbip host daemon
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/usbipd -D
ExecStartPost=/bin/bash -c '/usr/sbin/usbip_start.sh'
ExecStop=/bin/bash -c '/usr/sbin/usbip_stop.sh'

[Install]
WantedBy=multi-user.target
```
* systemctl --system daemon-reload
* systemctl enable usbipd.service
* systemctl start usbipd.service
* systemctl statu usbipd.service

## Install USBIP client on ubuntu
* apt install linux-tools-generic hwdata usbutils -y

### Load vhci_hcd kernel module
* modprobe vhci-hcd
* echo 'vhci-hcd' >> /etc/modules

### Create Start script
* nano /usr/sbin/usbip_start.sh

```
#!/bin/bash

server1='192.168.1.250'
usb1='303a:1001'
usb2='1a86:55d3'

/usr/bin/usbip attach -r $server1 -b $(/usr/bin/usbip list -r $server1 | grep $usb1 | cut -d: -f1)
/usr/bin/usbip attach -r $server1 -b $(/usr/bin/usbip list -r $server1 | grep $usb2 | cut -d: -f1)
```

* chmod +x /usr/sbin/usbip_start.sh
 
### Create stop script
* nano /usr/sbin/usbip_stop.sh

```
#!/bin/bash

/usr/bin/usbip detach --port=$(/usr/bin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')
/usr/bin/usbip detach --port=$(/usr/bin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')
```
* chmod +x /usr/sbin/usbip_stop.sh

# USBIP on OSX
* Devcontainer must run on DockerDesktop 4.35.0 or later
* [docker - doc - usbip](https://docs.docker.com/desktop/features/usbip/)

# Install USBIP in devcontainer on OSX Host
* apt install usbip hwdata usbutils -y

### Create Start script
* nano /usr/sbin/usbip_start.sh

```
#!/bin/bash

server1='192.168.1.250'
usb1='303a:1001'
usb2='1a86:55d3'

/usr/bin/usbip attach -r $server1 -b $(/usr/bin/usbip list -r $server1 | grep $usb1 | cut -d: -f1)
/usr/bin/usbip attach -r $server1 -b $(/usr/bin/usbip list -r $server1 | grep $usb2 | cut -d: -f1)
```

* chmod +x /usr/sbin/usbip_start.sh
 
### Create stop script
* nano /usr/sbin/usbip_stop.sh

```
#!/bin/bash

/usr/bin/usbip detach --port=$(/usr/bin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')
/usr/bin/usbip detach --port=$(/usr/bin/usbip port | grep '<Port in Use>' | sed -E 's/^Port ([0-9][0-9]).*/\1/')
```
* chmod +x /usr/sbin/usbip_stop.sh



# Serial 


crw-rw-rw- 1 root root 188, 0 Feb  8 12:07 /dev/ttyUSB0
crw-r--r-- 1 root root 188, 1 Feb  8 12:07 /dev/ttyUSB1
crw-r--r-- 1 root root 188, 2 Feb  8 12:07 /dev/ttyUSB2
│││││││││  │ │    │    │    │ └──────────┬──────────┘
│││││││││  │ │    │    │    │            └─ filename
│││││││││  │ │    │    │    └────────────── timestamp
│││││││││  │ │    │    └─────────────────── major, minor numbers
│││││││││  │ │    └──────────────────────── group (root)
│││││││││  │ └───────────────────────────── owner (root)
│││││││││  └─────────────────────────────── link count
│││││││││
││└─┴─┴──────────────────────────────────── permissions
││                                           owner: rw- (read, write)
││                                           group: r-- (read only)
││                                           other: r-- (read only)
│└────────────────────────────────────────── file type: w = write bit
└─────────────────────────────────────────── c = character device


(venv) root@df81bbc36aa3:/workspace# cat /proc/devices | grep tty
  4 tty
  4 ttyS
  5 /dev/tty
166 ttyACM
188 ttyUSB

Note: ttyACM -> 166, ttyUSB -> USB

View sysfs information:
ls -la /sys/class/tty/          # List all tty devices
cat /sys/class/tty/ttyUSB0/uevent    # Device details
ls -la /sys/module/ | grep -E "cp210x|ftdi|cdc"  # Find loaded modules

Check dmesg for driver messages:
dmesg -T | grep -E "tty|cp210x|ftdi|cdc_acm"

[Sun Feb  8 12:07:47 2026] cp210x 1-1:1.0: cp210x converter detected
[Sun Feb  8 12:07:47 2026] usb 1-1: cp210x converter now attached to ttyUSB0
[Sun Feb  8 12:07:47 2026] ftdi_sio 1-2:1.0: FTDI USB Serial Device converter detected
[Sun Feb  8 12:07:47 2026] usb 1-2: FTDI USB Serial Device converter now attached to ttyUSB1
[Sun Feb  8 12:07:47 2026] ftdi_sio 1-2:1.1: FTDI USB Serial Device converter detected
[Sun Feb  8 12:07:47 2026] usb 1-2: FTDI USB Serial Device converter now attached to ttyUSB2


Check driver binding:
readlink /sys/class/tty/ttyUSB0/device/driver
../../../../../../../bus/usb-serial/drivers/ftdi_sio

cat /sys/class/tty/ttyUSB1/device/uevent
DRIVER=ftdi_sio

Find locked Serial port
find /var/lock /run/lock -maxdepth 1 -type f -name 'LCK..*' -o -name '*ttyUSB0*' 