# Zehpyr Digikey Tutorial

## 1. Getting Started
### Workspace Structure

* [T3: Forest Topology](https://docs.zephyrproject.org/latest/develop/west/workspaces.html)
* [Zephyr RTOS](https://github.com/zephyrproject-rtos/zephyr)
* [Zephyr SDK](https://github.com/zephyrproject-rtos/sdk-ng)

### Start Docker Container
*  docker build -t env-zephyr-espressif -f ./Dockerfile.espressif .
*  docker run --rm -it -p 3333:3333 -v "${PWD}/workspace:/workspace" -w /workspace devcontainer-zephyr-esp32-xtensa-main

### Build code
* Change to project dir /workspace/apps/01_blink
* Set CONFIG_ESP32_USE_UNSUPPORTED_REVISION=y in prj.conf (Feather ESP32 uses an old V1.0 Core)
* Feather ESP32: west build -p always -b esp32_devkitc_wroom/esp32/procpu -- -DDTC_OVERLAY_FILE=boards/esp32_devkitc_wroom.overlay
* west build -p always -b esp32c6_devkitc -- -DDTC_OVERLAY_FILE=boards/esp32c6_devkitc.overlay -DCONFIG_BUILD_OUTPUT_HEX=y -DCONFIG_DEBUG=y -DOPENOCD=/opt/toolchains/debug/openocd-esp32/bin/openocd -DOPENOCD_DEFAULT_PATH=/opt/toolchains/debug/openocd-esp32/share/openocd/scripts


west build -p always -b esp32c6_devkitc 

west build -b esp32c6_devkitm -- -DCONFIG_BUILD_OUTPUT_HEX=y

west build -b esp32_devkitc_wrover/esp32/procpu 

#### TODO
* Shorten Commands with CMakePresets?
* Set ZEPHYR_TOOLCHAIN_VARIANT & ZEPHYR_SDK_INSTALL_DIR


### Flash code
#### esptool
* Check python version: python --version
* Setup virtual env: python -m venv venv
* Activate venv (on linux/max): source venv/bin/activate
* Install pyserial & esptool: python -m pip install pyserial==3.5 esptool==4.8.1
* ESP32-C6: python -m esptool --port /dev/tty.usbserial-1410 --chip auto --baud 921600 --before default_reset --after hard_reset write_flash -u --flash_size detect 0x0 ./workspace/apps/01_blink/build/zephyr/zephyr.bin


#### west
* Toolchains & Version infos -> west sdk 
* Kconfig -> west build -t menuconfig
* 
* esp runner
	* west flash --runner esp32 --esp-device /dev/ttyACM0 
	* west flash --runner esp32 --esp-device /dev/ttyUSB0
* openocd
	* west flash --runner openocd --openocd-extra-init "hla_serial 404CCA412C0C"
	* west flash --runner openocd --openocd-extra-init "adapter serial 404CCA412C0C"

	* west flash --runner openocd --openocd-extra-init "ftdi_serial 641a4254d544ed11a35bcec90a86e0b4"

	
* Get JTAG Device Serial
	* udevadm info --name=/dev/ttyACM0 --attribute-walk | grep serial
	* ATTRS{serial}=="40:4C:CA:41:2C:0C" -> 404CCA412C0C

## Zephyr
### TODO
* Fix Problems displayed on devcontainer startup

## 7. Debugging with OpenOCD and GDB
### OpenOCD
#### Links
* [https://openocd.org/](https://openocd.org/)
* [OpenOCD - Doc](https://openocd.org/doc-release/html/index.html)
* [OpenOCD - Github](https://github.com/openocd-org/openocd)
* [OpenOCD - Espressif - Github](https://github.com/espressif/openocd-esp32)
  
#### Install
* Download latest [openocd-esp32](https://github.com/espressif/openocd-esp32/releases)
* Move openocd-esp32 to /opt
* 
* unzip: tar -xzf openocd-esp32-*.tar.gz
* chown -R root:root openocd-esp32
* Add path to ~/.zshrc
  * export PATH=/opt/openocd-esp32/bin:$PATH
  * export OPENOCD_SCRIPTS=/path/to/openocd-esp32/share/openocd/scripts
  * openocd -f board/esp32c6-builtin.cfg
  * export PATH=/Applications/openocd-esp32/bin:$PATH
  * export OPENOCD_SCRIPTS=/path/to/openocd-esp32/share/openocd/scripts
openocd -f board/esp32c6-builtin.cfg

* openocd -f ./share/openocd/scripts/board/esp32c6-builtin.cfg 

#### Run (on host)
* openocd -s share/openocd/scripts/ -c 'set ESP_RTOS none; set ESP_FLASH_SIZE 0' -f board/esp32c6-builtin.cfg
* See also [openocd-esp32 on esp32-c6 (OCD-1053)](https://github.com/espressif/openocd-esp32/issues/350#issuecomment-2571331057)
* [OpenOCD config files](https://github.com/espressif/openocd-esp32/tree/master/tcl/board)

### GDB 
#### Links
* [GNU Project Debugger](https://sourceware.org/gdb/)
* [Quick Guide to GDB](https://beej.us/guide/bggdb/)
#### Run GDB (in devcontainer)
* /opt/toolchains/zephyr-sdk-0.17.4/riscv64-zephyr-elf/bin/riscv64-zephyr-elf-gdb build/zephyr/zephyr.elf
* (gdb) target remote localhost:3333

### USB / Serial Ports
* /dev/ttyACM0 -> Bus 002 Device 020: ID 303a:1001 Espressif USB JTAG/serial debug unit
* /dev/ttyUSB0 -> Bus 002 Device 019: ID 10c4:ea60 Silicon Labs CP210x UART Bridge
* 
### UDEV Rules -> Must be run on host !
* [Zephyr RTOS on ESP32 install](https://developer.espressif.com/blog/zephyr-rtos-on-esp32-first-steps/)
* [Set up Nordic nRF Connect SDK](https://docs.golioth.io/getting-started/device-examples/compile-example-code/zephyr-ncs/set-up-ncs/#install-the-zephyr-sdk-toolchain)
sudo cp ~/zephyr-sdk-0.17.4/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60- openocd.rules /etc/udev/rules.d
* sudo udevadm control --reload
* ./setup.sh

#### Debugging
* mon reset halt


## Todo
* WebServer / ssh  entfernen
* USBIP auf osx, win und Linux aufsetzen
* docker image erweitern
	* usbip
	* OpenOCD
	* webserver entfernen? switch?	
* OpenOCD
	* Autostart OpenOCD with Debbuger
	* JTag connect / disconnect
* Compiler für debug optimieren / West?
* Readme.md erstellen
* DevContainer MCU Stacks
	* ESP32-RISCV
	* ESP32-Extensa
	* nRF5x-ARM
	* STM32-ARM
	* 


## Extensions
*C/C++ Extension Pack



