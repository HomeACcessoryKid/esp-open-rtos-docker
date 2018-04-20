FROM debian:stable-slim
LABEL maintainer="Erwin Boskma <erwin@datarift.nl>"
LABEL version="1.0"

RUN apt-get update && apt-get install -y make unrar-free autoconf automake libtool gcc g++ gperf \
  flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python-serial python-pip \
  sed git unzip bash help2man wget bzip2 libtool-bin && apt-get clean

RUN mkdir /esp8266 && mkdir /app
WORKDIR /esp8266

RUN adduser --shell /bin/sh --disabled-password --quiet espbuild
RUN chown espbuild:espbuild /esp8266 /app

USER espbuild

RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk && \
  git clone --recursive https://github.com/SuperHouse/esp-open-rtos

RUN cd esp-open-sdk && make toolchain esptool libhal STANDALONE=n && pip install esptool

WORKDIR /app
ENV PATH=/esp8266/esp-open-sdk/xtensa-lx106-elf/bin:$PATH SDK_PATH=/esp8266/esp-open-rtos

VOLUME [ "/app" ]

ENTRYPOINT [ "sh", "-c", "make -j$(nproc)" ]
