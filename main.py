from time import sleep
import urequests as requests
import ujson

config_file = open('config.json', 'r')
config = ujson.loads(config_file.read())
config_file.close()

request_url = config['webhookURL']

def main():
    while True:
        try:
            value = 27.4
            print('Value: %3.1f' %value)
            message = 'The value is %s' %(value)
            post_data = ujson.dumps({ 'text': message })
            try:
                requests.post(request_url, headers = {'content-type': 'application/json'}, data = post_data).json()
            except:
                pass
            sleep(5)
        except OSError as e:
            print('Failed something')
            raise e

main()