from time import sleep
import urequests as requests
import ujson

config_file = open('config.json', 'r')
config = ujson.loads(config_file.read())
config_file.close()

watch_url = config.get('watchURL')
notify_url = config.get('notifyURL')

def notify(notify_url, data):
    post_data = ujson.dumps({ 'data': data })
    try:
        requests.post(notify_url, headers = {'content-type': 'application/json'}, data = post_data)
    except:
        pass

def watch(watch_url):
    try:
        requests.head(watch_url)
        return True
    except:
        return False

def main():
    while True:
        try:
            all_good = watch(watch_url)
            if not all_good:
                notify(notify_url, "Something is wrong")
            sleep(5)
        except OSError as e:
            print('Failed something')
            raise e

main()
