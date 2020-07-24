FROM mitchins/micropython-linux

WORKDIR /app

COPY . /app
RUN /app/setup.sh

CMD ["/usr/local/bin/micropython", "/app/main.py"]
