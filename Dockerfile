FROM debian:stable-slim
LABEL maintainer="HacK <HomeACcessoryKid@gmail.com>"
LABEL version="1.0"
# 2022 'seems to work' Dockerfile for esp-open-rtos without serial port support.
# Use a native ESPTOOL deployment to flash the firmware files

RUN apt-get update && apt-get install -y make unrar-free autoconf automake libtool gcc g++ gperf \
  flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python3-pip \
  sed git unzip bash help2man wget bzip2 libtool-bin xxd && apt-get clean

RUN mkdir /esp8266 && mkdir /project
WORKDIR /esp8266

RUN adduser --shell /bin/sh --disabled-password --quiet espbuild
RUN chown espbuild:espbuild /esp8266 /project

USER espbuild

RUN git clone --recursive https://github.com/pfalcon/esp-open-sdk && \
  git clone --recursive https://github.com/SuperHouse/esp-open-rtos

RUN cd esp-open-sdk && git submodule update --remote --merge crosstool-NG
RUN find esp-open-sdk/crosstool-NG -name "???-isl.sh"   -exec sed -i.orig s/isl.gforge.inria.fr/libisl.sourceforge.io/ \{\} \;
RUN find esp-open-sdk/crosstool-NG -name "???-expat.sh" -exec sed -i.orig sYhttp://downloads.sourceforge.net/project/expat/expat/\$\{CT_EXPAT_VERSION\}Yhttps://github.com/libexpat/libexpat/releases/download/R_2_1_0/Y \{\} \;
RUN cd esp-open-sdk && make toolchain esptool libhal STANDALONE=n && pip install esptool
RUN find esp-open-sdk -name esptool.py   -exec sed -i.orig s/import\ serial/\#import\ serial/ \{\} \;

#these lines are for HacK purposes only and can be skipped. they do not change normal behavior though.
RUN cd esp-open-rtos/ld && cp program.ld program1.ld && sed -i s/0x40202010/0x4028D010/ program1.ld
RUN cd esp-open-rtos && sed -i -E 'sY\+\=\ \$\(ROOT\)ld/program.ld\ \$\(ROOT\)ld/rom.ldY\?\=\ \$\(ROOT\)ld/program.ld\nLINKER_SCRIPTS\ +=\ \$\(ROOT\)ld/rom.ldY' parameters.mk

WORKDIR /project
ENV PATH=/esp8266/esp-open-sdk/xtensa-lx106-elf/bin:$PATH SDK_PATH=/esp8266/esp-open-rtos
