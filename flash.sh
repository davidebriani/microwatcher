#!/usr/bin/env bash
set -o errexit -o pipefail -o noclobber -o nounset -o errtrace
traperr() {
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
  exit 1
}
trap traperr ERR
pushd "$(dirname "$0")" >/dev/null

usbserial=$(find /dev -maxdepth 1 -name "cu.usbserial*") # Find device with MacOS naming...
device=${usbserial:-"/dev/ttyUSB0"} # ...otherwise use the default Linux device name
[ ! -f $device ] && echo "Could not find a esp8266 device" && exit 1
echo "The target is set to be $device"

if [ -z "$PS1" ]; then
    echo This shell is not interactive, proceeding...
else
    read -p "Are you sure to proceed? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    fi
fi

echo "Will now install dependencies..."
pip -q install --upgrade esptool mpfshell
echo "Will now download the firmware..."
wget -q -O micropython.bin http://micropython.org/resources/firmware/esp8266-20191220-v1.12.bin
echo "Will now erase the flash..."
esptool.py --port $device erase_flash
sleep 3
echo "Will now deploy the firmware..."
esptool.py --port $device --baud 460800 write_flash --flash_size=detect 0 micropython.bin

# TODO: reboot device to allow micropython to load

echo "Will now configure the device..."
mpfshell -n -c "open ${device##*/}; put boot.py; put main.py; put config.json"
echo "Will now reboot the device..."
mpfshell --reset -n -c "open ${device##*/}"