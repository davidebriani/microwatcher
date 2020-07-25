# This file is executed on every boot (including wake-boot from deepsleep)
# import esp
# esp.osdebug(None)
import uos, machine
# uos.dupterm(None, 1) # disable REPL on UART(0)
import gc
import network
import ujson

gc.collect()

config_file = open('config.json', 'r')
config = ujson.loads(config_file.read())
config_file.close()

sta_if = network.WLAN(network.STA_IF)
wifi_ssid = config.get('wifiSSID')
wifi_password = config.get('wifiPassword')
if not sta_if.isconnected() and wifi_ssid and wifi_password:
    print('Connecting to network...')
    sta_if.active(True)
    sta_if.connect(wifi_ssid, wifi_password)
    while not sta_if.isconnected():
        pass
print('Network config:', sta_if.ifconfig())
