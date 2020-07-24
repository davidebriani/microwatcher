# This file is executed on every boot (including wake-boot from deepsleep)
# import esp
# esp.osdebug(None)
import uos, machine
# uos.dupterm(None, 1) # disable REPL on UART(0)
import gc
import webrepl
import network
import ujson

webrepl.start()
gc.collect()

config_file = open('config.json', 'r')
config = ujson.loads(config_file.read())
config_file.close()

sta_if = network.WLAN(network.STA_IF)
if not sta_if.isconnected() and config['wifiSSID'] and config['wifiPassword']:
    print('Connecting to network...')
    sta_if.active(True)
    sta_if.connect(config['wifiSSID'], config['wifiPassword'])
    while not sta_if.isconnected():
        pass
print('Network config:', sta_if.ifconfig())
