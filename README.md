# Microwatcher

A simple python app that runs in micropython environments too. Aimed at ESP8266 microcontrollers.
It watches some websites for changes and notifies about the new data.

## Project structure

- `main.py` is the app's entrypoint and contains the main loop
- `boot.py` is an entrypoint used by micropython when on a microcontroller
- `setup.sh` is used in Docker to install required dependencies before calling `main.py`
- `flash.sh` is used to flash the app into a microcontroller

## 1. Setup

```sh
cp config.json.sample config.json
```

And edit `config.json` as needed.

## 2. Local dev

```sh
docker-compose up
```

If you make changes to the app's code in `main.py`, you just have to stop docker-compose with `CTRL+C` and spin docker-compose up again.

If you need more setup or dependencies, edit `setup.py` and rebuild the docker image with:

```sh
docker-compose --build up
```

## 3. Deploy

### Flashing your ESP8266

Be sure to have `wget` and Python + `pip` installed, then attach the ESP via USB and:

```sh
./flash.sh
```

### With Docker

```sh
docker -t microwatcher .
docker run microwatcher
```
