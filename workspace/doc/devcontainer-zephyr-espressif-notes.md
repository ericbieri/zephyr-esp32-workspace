# DevContainer Zehpyr Espressif Notes 

## Start DevContainer
* Reopen Project in Container -> Command Palette (Ctrl+Shift+P, F1)
* Check in devcontainer.json if DevContainer is build from image (default) or build.
* The checkout's `repos/` directory is bind-mounted at `/repos` inside the container. Create it on the Docker host before reopening (`mkdir -p repos` from the project root); it is not tracked by Git. The source uses `${localWorkspaceFolder}/repos`, not the host's `/repos`.
* After changing mounts, run **Dev Containers: Rebuild and Reopen in Container** from the Command Palette.

###  Links
* [VS Code - Keyboard shortcuts](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-linux.pdf)

## How to list Board targets
* west boards | grep esp32h2_devkitm 
* west boards --all-targets --name esp32h2_devkitm

## Build code
* Change to project dir /workspace/apps/01_blink

## Synch modules
* west list | grep hal_espressif
* Synch modules west update hal_espressif

### ESP32
* Set CONFIG_ESP32_USE_UNSUPPORTED_REVISION=y in prj.conf (Feather ESP32 uses an old V1.0 Core)
* west build -p always -b esp32_devkitc_wroom/esp32/procpu -- -DDTC_OVERLAY_FILE=boards/esp32_devkitc_wroom.overlay debug/openocd-esp32/bin/openocd -DOPENOCD_DEFAULT_PATH=/opt/toolchains/debug/xpack-openocd-0.12.0-7/openocd/scripts/ -DCONFIG_BUILD_OUTPUT_HEX=y 
* west build -b esp32_devkitc_wrover/esp32/procpu 
* Test in PIO to see what the openocd string looks like

west build -p always \
  -b esp32_devkitc/esp32/procpu \
  -d build-esp32 \
  -- \
  -DDTC_OVERLAY_FILE=boards/esp32_devkitc_wroom.overlay \
  -DOPENOCD=/opt/openocd/bin/openocd \
  -DOPENOCD_DEFAULT_PATH=/opt/openocd/share/openocd/scripts \
  -DCONFIG_BUILD_OUTPUT_HEX=y

### ESP32-S3
* west build -p always \
  -b esp32s3_devkitc/esp32s3/procpu \
  -d build-esp32s3 \
  -- \
  -DDTC_OVERLAY_FILE=boards/esp32s3_devkitc.overlay \
  -DOPENOCD=/opt/openocd/bin/openocd \
  -DOPENOCD_DEFAULT_PATH=/opt/openocd/share/openocd/scripts \
  -DCONFIG_BUILD_OUTPUT_HEX=y

cd /workspace
west update hal_espressif
west blobs fetch hal_espressif


### ESP32-C6
* west build -p always -b esp32c6_devkitc -- -DDTC_OVERLAY_FILE=boards/esp32c6_devkitc.overlay -DCONFIG_BUILD_OUTPUT_HEX=y -DCONFIG_DEBUG=y -DOPENOCD=/opt/toolchains/

#### TODO
* Shorten Commands with CMakePresets?
* Set ZEPHYR_TOOLCHAIN_VARIANT & ZEPHYR_SDK_INSTALL_DIR

## Flash code
### VS Code OpenOCD task
* Run **Tasks: Run Task** and select **west flash-OpenOCD**.
* Uses `west flash --runner openocd --build-dir build-${config:esp32.variant} --config /workspace/openocd/openocd-${config:esp32.variant}-zephyr.cfg --verify` from the configured `project.root`.
* Uses the selected build's firmware image and flash address, verifies flash contents, and resets the board to run.
* Uses the workspace's Zephyr-specific OpenOCD configuration, including its `esp appimage_offset` flash mapping. Keep that offset aligned with the build's `CONFIG_FLASH_LOAD_OFFSET` when changing the boot layout.
* Connect the board's JTAG interface (ESP32-S3 builtin USB-JTAG, or the board's configured external adapter). The serial `flash.device` setting is not used.
* Stop any running OpenOCD task or debug session before flashing so the adapter is available.

### west
* __Toolchains & Version infos__: west sdk 
* __Kconfig__: west build -t menuconfig
* __Flash with ESP Runner__cd b
	* west flash --runner esp32 --build-dir build-esp32s3 --esp-device /dev/ttyACM0
	* west flash --runner esp32 --build-dir build-esp32s3 --esp-device /dev/ttyACM1	// J-TAG

	* west flash --runner esp32 --build-dir build-esp32 --esp-device /dev/ttyUSB1
	
	TIP: get USB to tty mapping: dmesg -T | grep tty
* // TODO verify & fix __OpenOCD__ 
	* west flash --runner openocd --openocd-extra-init "hla_serial 5A79065086"
	* west flash --runner openocd --openocd-extra-init "adapter serial 5A79065086"
	* west flash --runner openocd --openocd-extra-init "ftdi_serial 641a4254d544ed11a35bcec90a86e0b4"

* flashing using openocd
	* /opt/toolchains/debug/openocd-esp32/bin/openocd \
		-s /opt/toolchains/debug/openocd-esp32/share/openocd/scripts \
		-f interface/ftdi/esp_ftdi.cfg \
		-f target/esp32.cfg \
		-c "adapter speed 20000" \
		-c "init; halt; program_esp /workspace/01_blink/build/zephyr/zephyr.bin 0x10000 verify reset exit"
	
* __Get JTAG Device Serial__
	* udevadm info --name=/dev/ttyACM0 --attribute-walk | grep serial
	* ATTRS{serial}=="40:4C:CA:41:2C:0C" -> 404CCA412C0C

### esptool // TODO test & fix
* Check python version: python --version
* Setup virtual env: python -m venv venv
* Activate venv (on linux/mac): source venv/bin/activate
* Install pyserial & esptool: python -m pip install pyserial==3.5 esptool==4.8.1
* ESP32-C6: python -m esptool --port /dev/ttyACM0 --chip auto --baud 921600 --before default_reset --after hard_reset write_flash -u --flash_size detect 0x0 ./workspace/apps/01_blink/build/zephyr/zephyr.bin

# Debugging with OpenOCD and GDB
## OpenOCD
### Links
* [https://openocd.org/](https://openocd.org/)
* [OpenOCD - Doc](https://openocd.org/doc-release/html/index.html)
* [OpenOCD - Github](https://github.com/openocd-org/openocd)
* [OpenOCD - Espressif - Github](https://github.com/espressif/openocd-esp32)
* [Espressif - Configure ESP32-S3 Built-in JTAG Interface](https://docs.espressif.com/projects/esp-idf/en/latest/esp32s3/api-guides/jtag-debugging/configure-builtin-jtag.html)
* [Espressif - Debug with ESP32Prog](https://blog.berrybase.de/esp32-debuggen-mit-espressif-esp-prog-platformio/)
* [Youtube - ESP32 Debugging your ESP-IDF code using JTAG](https://www.youtube.com/watch?v=uq93H7T7cOQ)

### Run
// TODO Shorten Path add to PATH?
* openocd -f /opt/toolchains/debug/xpack-openocd-0.12.0-7/openocd/scripts/board/esp32s3-builtin.cfg
* openocd -f /opt/toolchains/debug/openocd-esp32/share/openocd/scripts/board/esp32s3-builtin.cfg
* 

### Run OpenOCD inside VSCode
* Build and flash the selected application first; starting the debugger does not flash it.
* Run **Tasks: Run Task > OpenOCD** and leave that task running.
* Select **GDB-Debugger** in **Run and Debug**, then press **F5**.
* The [launch configuration](../.vscode/launch.json) connects to OpenOCD on `127.0.0.1:3333`, resets and halts the target, then continues to `main`.
* For the current ESP32-C6 Zephyr simple-boot build, OpenOCD reports no IROM/DROM mapping. The launch configuration marks the C6 mapped-flash window (`0x42000000` to `0x43000000`, end exclusive) read-only so GDB uses a hardware breakpoint for the entry stop. This is a CPU address range, not a flash programming offset.
* User breakpoints also use hardware, limited to two concurrent instruction breakpoints. The entry breakpoint is removed once `main` is reached.
* The current configuration uses the RISC-V GDB and C6 flash window; review those settings before switching to an Xtensa board.
* If OpenOCD reports USB/JTAG transport errors, stop the debug session and restart the **OpenOCD** task before retrying. Only one OpenOCD process should own the adapter.

### Run on host - deprecated
* openocd -s share/openocd/scripts/ -c 'set ESP_RTOS none; set ESP_FLASH_SIZE 0' -f board/esp32c6-builtin.cfg
* See also [openocd-esp32 on esp32-c6 (OCD-1053)](https://github.com/espressif/openocd-esp32/issues/350#issuecomment-2571331057)
* [OpenOCD config files](https://github.com/espressif/openocd-esp32/tree/master/tcl/board)

#### Install manually
* Download latest [openocd-esp32](https://github.com/espressif/openocd-esp32/releases)
* Move openocd-esp32 to /opt
* USB
* unzip: tar -xzf openocd-esp32-*.tar.gz
* chown -R root:root openocd-esp32
* Add path to ~/.zshrc
  * export PATH=/opt/openocd-esp32/bin:$PATH
  * export OPENOCD_SCRIPTS=/path/to/openocd-esp32/share/openocd/scripts
  * openocd -f board/esp32c6-builtin.cfg
  * export PATH=/Applications/openocd-esp32/bin:$PATH
  * export OPENOCD_SCRIPTS=/path/to/openocd-esp32/share/openocd/scripts
openocd -f board/esp32c6-builtin.cfg

### OpenOCD debian - 2026.10.14
  "runArgs": [
    "--privileged",
    "--volume=/dev/bus/usb:/dev/bus/usb",
    "--device-cgroup-rule=c 189:* rmw"
  ]

ls -l /dev/bus/usb/*/*

/opt/toolchains/debug/openocd-esp32/bin/openocd \
  -s /opt/toolchains/debug/openocd-esp32/share/openocd/scripts \
  -f board/esp32s3-builtin.cfg \
  -c 'set ESP_RTOS none' \
  -c 'adapter speed 20000' \
  -c 'tcl port 6666' \
  -c 'telnet port 4444' \
  -c 'gdb port 3333'

sudo apt install -y iputils-ping





## GDB 
### Links
* [GNU Project Debugger](https://sourceware.org/gdb/)
* [Quick Guide to GDB](https://beej.us/guide/bggdb/)
* [Espressif IDF - Debug Project in VSCode](https://docs.espressif.com/projects/vscode-esp-idf-extension/en/latest/debugproject.html)

### Run GDB (in devcontainer)
* /opt/toolchains/zephyr-sdk-0.17.4/xtensa-espressif_esp32s3_zephyr-elf/bin/xtensa-espressif_esp32s3_zephyr-elf-gdb build/zephyr/zephyr.elf
* /opt/toolchains/zephyr-sdk-0.17.4/xtensa-espressif_esp32_zephyr-elf/bin/xtensa-espressif_esp32_zephyr-elf-gdb build/zephyr/zephyr.elf
### Debugging - GDB CLI
* target extended-remote localhost:3333
* mon reset halt
* optional: file /workspace/01_blink/build/zephyr/zephyr.elf
* For ESP32-S3 flash software breakpoints, set `esp appimage_offset 0x10000` in the OpenOCD command line or config file before GDB connects. Setting it later with `monitor esp appimage_offset 0x10000` is too late for the initial memory map.
* For ESP32-S3 code running from flash (`0x4200....`), GDB may use either hardware breakpoints or OpenOCD-managed flash software breakpoints when flash mappings are configured correctly.
* IRAM code can use normal software breakpoints directly because that memory is writable.
* The chip only has 2 true hardware breakpoints, so keep at least one free when you want `next` to step over calls reliably.
* hbreak main
* hbreak main.c:31
* continue
* list
* detach
* exit

# UDEV Rules (Must be installled on host OS)
udev (userspace /dev) is a device manager for the Linux kernel. udev primarily manages device nodes in the /dev directory. At the same time, udev also handles all user space events raised when hardware devices are added into the system or removed from it, including firmware loading as required by certain devices.

## UDEV Rules files
* __PlatformIO UDEV Rules__ 
	* [PlatformIO - Doc - UDEV Rules](https://docs.platformio.org/en/stable/core/installation/udev-rules.html)
	* [Github - PlatformIO - 99-platformio-udev.rules](https://raw.githubusercontent.com/platformio/platformio-core/develop/platformio/assets/system/99-platformio-udev.rules)
* __Zephyr SDK - UDEV Rules__ 
	* [Github - Zephyrproject - SDK](https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.4/zephyr-sdk-0.17.4_linux-x86_64_minimal.tar.xz)
* __Install & Reload UDEV Rules__ 
	* cp /zephyr-sdk-0.17.4/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules /etc/udev/rules.d
	* sudo udevadm control --reload


## Extensions
* gitrepo Extension Frage ausblenden?

# Hardware
* [Zephyr - ESP32-S3-DevKitC](https://docs.zephyrproject.org/latest/boards/espressif/esp32s3_devkitc/doc/index.html)

# USB to Serial Chipsets
* CP210x: brew install --cask silicon-labs-vcp-driver
* CH3340
	* https://github.com/WCHSoftGroup/ch34xser_macos
	* PDF genau studieren
	* Systemeinstellungen/Allgemein/Anmeldeobjekte & Erweiterungen/Treibererweiterungen -> click (i) -> enable Treibererweiterungen
* FT2232: brew install --cask ftdi-vcp-driver



# Zephyr Tutorials
* [Introduction to Zephyr - Digikey](https://www.youtube.com/watch?v=mTJ_vKlMS_4&list=PLEBQazB0HUyTmK2zdwhaf8bLwuEaDH-52)
* [ESP32 on Zephyr OS](https://www.youtube.com/watch?v=Z_7y_4O7yTw&list=PLEQVp_6G_y4iFfemAbFsKw6tsGABarTwp)
* [Set up Nordic nRF Connect SDK](https://docs.golioth.io/getting-started/device-examples/compile-example-code/zephyr-ncs/set-up-ncs/#install-the-zephyr-sdk-toolchain)


## Links
### DevContainer
* https://code.visualstudio.com/docs/devcontainers/containers
* https://mcuoneclipse.com/wp-content/uploads/2025/02/vs-code-devcontainer-with-debugging.png

### JLink
* https://mcuoneclipse.com/2025/02/18/remote-debugging-with-devcontainer-and-vs-code/

### JTAG
* https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/jtag-debugging/index.html
* https://www.visualmicro.com/page/User-Guide.aspx?doc=index

### Datasheets
* https://documentation.espressif.com/esp32-s3_datasheet_en.pdf

### Hardware / DevKits 
* [ESP32-S3-DevKit-C](https://docs.espressif.com/projects/esp-dev-kits/en/latest/esp32s3/esp32-s3-devkitc-1/user_guide_v1.1.html#getting-started)

## Todo
* Configuration
	*  CLI/west nutzen ohne immer alle Optionen mitgeben zu müssen. 

* Docker
	* Initial .vscode settings!?
	* USBIP auf osx, win und Linux aufsetzen
	* Entferne ungebrauchte ENV variablen
	* Release Notes mit Versionen generieren
	* Release Please einführen
	* Renovate einführen

* OpenOCD
	* Autostart OpenOCD with GDB?

* GDB
	* ESP32(S2) + ESP32Prog
	
* west
	* Compiler für debug optimieren / west?

* USB Ports / USBIP
	* Linux
	* Windows 

* Program
	* Demo Blinky

* Github
	* Definitiver Github Account? Space for Embedded DevContainers?
	* Release Notes with Versions also on Dockerhub?

* Extensions
	* Nordic Extensions

* Documentation
	* Wiki Pages on Github
	* QuickStart (ESP32, ESP32-S2, ESP32-S3 DevKits)
	* Introduction
		* Goals (Pain, Complexity, Lightweight)
			* What is the container for, what not?
		* Zephyr
		* Devcontainer Intro
	* Debug 
	* Install
		* Prerequisites
		* Host Setup
			* Linux
			* Windows
			* Mac
		* USBIP RPI Client Setup
			* Start/Stop Scripts
	* Links Page?
	
* DevContainer MCU Stacks
	* ESP32-RISCV / ESP32-Xtensa
	* nRF5x-ARM
	* STM32-ARM
	* RPI-Pico


# Zephyr Project Structure

Current topology: separate manifest directory
-------------------------------------------
The active workspace manifest is `/workspace/manifest/west.yml`.
It pins Zephyr to `v4.4.2`, records the workspace dependencies, and loads
Zephyr's west commands. `/workspace/zephyr/west.yml` is no longer the
workspace's entry-point manifest.

`/workspace/.west/config` selects the manifest directory and keeps the
Zephyr source directory separate:

```ini
[manifest]
path = manifest
file = west.yml

[zephyr]
base = zephyr
```

To verify the configuration:

```sh
cd /workspace
west manifest --path
west manifest --validate
west list zephyr hal_espressif hal_xtensa picolibc
```

After changing the pinned Zephyr version, run `west update` to synchronize
dependencies before rebuilding. Application manifests under `repos/` are
independent and do not select this workspace's active manifest.

Current separate-manifest topology
----------------------------
workspace/                     # west topdir
├── .west/                     # marks the location of the topdir
│   └── config                 # per-workspace local configuration file
│
│   # Workspace manifest, maintained separately from Zephyr:
├── manifest/
│   └── west.yml               # pins Zephyr and imports its manifest
│
│   # Projects managed by west:
├── zephyr/                    # upstream .git/ project, pinned to v4.4.2
│   ├── west.yml               # imported upstream dependency manifest
│   └── [... other files ...]
│
├── modules/
│   └── lib/
│       └── zcbor/             # .git/ project
│
├── tools/
│   └── net-tools/  
│
├── bootloader/  
│
├── applications/
│   ├── blinky/
│   └── hello-world/
