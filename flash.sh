#!/usr/bin/env bash
set -o errexit -o pipefail -o noclobber -o nounset -o errtrace
traperr() {
  echo "ERROR: ${BASH_SOURCE[1]} at about ${BASH_LINENO[0]}"
  exit 1
}
trap traperr ERR
pushd "$(dirname "$0")" >/dev/null

LATEST_MICROPYTHON_ESP8266="http://micropython.org/resources/firmware/esp8266-20191220-v1.12.bin"
LATEST_MICROPYTHON_ESP32="https://micropython.org/resources/firmware/esp32-idf3-20191220-v1.12.bin"

echo "Will now install dependencies..."
pip -q install --upgrade esptool mpfshell

echo "Will now detect if you are using a virtualenv..."
python_bins=""
if [[ "$VIRTUAL_ENV" != "" ]]; then # if on a VirtualEnv
    # find path for binaries since we will launch them via sudo and they won't be in PATH
    env_name=$(basename $VIRTUAL_ENV)
    python_bins=$HOME/.virtualenvs/$env_name/bin/
fi

echo "Will now look for attached devices..."
usbserial=$(find /dev -maxdepth 1 -name "cu.usbserial*") # Find device with MacOS naming...
ttydevice=$(find /dev -maxdepth 1 -name "ttyUSB0") # ...otherwise use the default Linux device name
device=${usbserial:-$ttydevice}
[[ ! -c $device ]] && echo "Could not find the right character device. Will now exit." && exit 1

echo "Found device $device. We will erase it and load a suitable firmware."
if tty -s; then
    read -p "Are you sure to proceed? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    fi
else
    echo "This shell is not interactive, will skip confirmation..."
fi

echo "Will now check the chip version..."
chip_info=$(sudo ${python_bins}esptool.py --port /dev/ttyUSB0 chip_id)
case "$chip_info" in 
  *ESP8266*)
    echo "The device was recognized as a ESP8266"
    micropython_url=$LATEST_MICROPYTHON_ESP8266
    ;;
  *ESP32*)
    echo "The device was recognized as a ESP32"
    micropython_url=$LATEST_MICROPYTHON_ESP32
    ;;
  *)
    echo "This device is not a ESP8266 or ESP32. Will now exit."
    exit 1
esac

echo "Will now download the firmware..."
wget -q -O micropython.bin $micropython_url
echo "Will now erase the flash..."
sudo ${python_bins}esptool.py --port $device erase_flash
sleep 3
echo "Will now deploy the firmware..."
sudo ${python_bins}esptool.py --port $device --baud 460800 write_flash --flash_size=detect 0 micropython.bin

echo "Will now reboot the device to boot into micropython..."
sudo ${python_bins}mpfshell --reset -n -c "open ${device##*/}"
echo "Will now upload the app to micropython..."
sudo ${python_bins}mpfshell -n -c "open ${device##*/}; put boot.py; put main.py; put config.json"
echo "Will now reboot the device to start the app..."
sudo ${python_bins}mpfshell --reset -n -c "open ${device##*/}"
echo "Up and running!"
echo "You can read logs from your app by listening on the USB serial connection."
echo "To do so, run \"sudo screen $device 115200\". Then Ctrl+a to exit."
