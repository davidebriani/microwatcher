# Microwatcher

A simple uptime monitor as a micropython app. Aimed at ESP8266 / ESP32 microcontrollers.
When the given URL becomes unreachable, the app notifies you via a POST request to the webhook of your choice: you could use SendGrid Web APIs to email you a message.

Project structure:

- `main.py` is the app's entrypoint and contains the main loop
- `boot.py` is an entrypoint used by micropython when on a microcontroller
- `setup.sh` is used in Docker to install required dependencies before calling `main.py`
- `flash.sh` is used to flash the app into a microcontroller

## 1. Setup

```sh
cp config.json.sample config.json
```

And edit `config.json` as needed.

## 2. Local development

```sh
docker-compose up
```

As of now, if you make changes to the app's code in `main.py`, you just have to stop docker-compose with `CTRL+C` and spin docker-compose up again.

If you need more setup or dependencies, edit `setup.py` and rebuild the docker image with:

```sh
docker-compose --build up
```

Please note that running the app on your computer is not the same as running it on a microcontroller. On the latter, for instance, you could encounter issues because of the small space available for RAM and storage.

## 3. Deploy

### Flashing your ESP8266

Be sure to have `wget` and Python + `pip` installed. Optionally create a python virtualenv:

```sh
mkvirtualenv microwatcher
```

Then grab a short and good quality USB cable, attach the ESP via USB, and:

```sh
./flash.sh
```

The script will try to automatically detect your device and you will be asked to confirm it is the one to flash.

### With Docker

```sh
docker -t microwatcher .
docker run microwatcher
```
