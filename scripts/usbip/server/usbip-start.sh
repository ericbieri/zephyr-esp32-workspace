#!/bin/bash

# ESP32-S3 DevKitC USBs <VendorID>:<DeviceID>
usb1='303a:1001'
usb2='1a86:55d3'

sudo /usr/bin/usbip bind --$(/usr/bin/usbip list -p -l | grep '#usbid='$usb1'#' | cut -d'#' -f1)
sudo /usr/bin/usbip bind --$(/usr/bin/usbip list -p -l | grep '#usbid='$usb2'#' | cut -d'#' -f1)