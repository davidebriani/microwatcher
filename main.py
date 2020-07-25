from time import sleep
import urequests as requests
import ujson

config_file = open('config.json', 'r')
config = ujson.loads(config_file.read())
config_file.close()

request_url = config.get('webhookURL')

def notify(data):
    post_data = ujson.dumps({ 'data': data })
    try:
        requests.post(request_url, headers = {'content-type': 'application/json'}, data = post_data).json()
    except:
        pass

# A watcher is given a previous state and checks if a new state exists
# Returns the new state to notify the main loop, otherwise returns None
def subito_watcher(state = {}):
    previous_ad_id = state.get('id')
    request_url = "https://www.subito.it/hades/v1/search/items?t=s&qso=false&sort=datedesc&lim=1&start=0"
    result = requests.get(request_url).json()
    ads = result.get('ads', [])
    latest_ad = ads[0] if len(ads) > 0 else {}
    latest_ad_id = latest_ad.get('urn')
    latest_ad_url = latest_ad.get('urls', {}).get('default')
    if latest_ad_id == previous_ad_id:
        return None
    return { 'id': latest_ad_id, 'url': latest_ad_url }

watchers = { 'subito': subito_watcher }

def main():
    while True:
        try:
            for watcher_name, watcher_fn in watchers.items():
                config_file = open('config.json', 'r')
                config = ujson.loads(config_file.read())
                config_file.close()
                watcher_state = config.get(watcher_name, {})
                new_watcher_state = watcher_fn(watcher_state)
                if new_watcher_state:
                    config[watcher_name] = new_watcher_state
                    config_file = open('config.json', 'w')
                    config_file.write(ujson.dumps(config))
                    config_file.close()
                    notify(new_watcher_state)
            sleep(60) # Wait 60 seconds before polling again
        except OSError as e:
            print('Failed something')
            raise e

main()