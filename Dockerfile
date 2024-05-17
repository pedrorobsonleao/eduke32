FROM ubuntu:latest AS build

WORKDIR eduke32

COPY . /eduke32

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=America/Sao_Paulo

RUN \
    apt update -y --no-install-recommends && \
    apt install -y \
    build-essential \
    nasm \
    libgl1-mesa-dev \
    libsdl2-dev \
    flac \
    libflac-dev \
    libvpx-dev \
    libgtk2.0-dev \
    freepats \
    xpra \
    git-all && \
	apt-get -y --purge autoremove && \
    apt-get clean && \
    rm -vrf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    make RELEASE=0 && \
    git clone https://github.com/ninjada/eduke32.git config_eduke32 

FROM ubuntu:latest AS target

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
	apt-get -y install  \
    xpra  \
    libsdl2-2.0-0 && \
	apt-get -y --purge autoremove && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /eduke32

COPY --from=build /eduke32/eduke32 .
COPY --from=build /eduke32/mapster32 .
COPY --from=build /eduke32/config_eduke32 /root/.config/eduke32
COPY --from=build /eduke32/.run_in_xpra /run_in_xpra

RUN rm -rf  /root/.config/eduke32/EDuke32.app \
            /root/.config/eduke32/.git && \
            sed -e 's/ScreenBPP = 32/ScreenBPP = 8/; s/ScreenHeight = 1200/ScreenHeight = 640/; s/ScreenWidth = 1920/ScreenWidth = 480/' -i /root/.config/eduke32/eduke32.cfg
#USER eduke32

ENV XPRA_DISPLAY=":100"

ARG XPRA_PORT=10000
ENV XPRA_PORT=$XPRA_PORT
EXPOSE $XPRA_PORT

CMD ["bash", "/run_in_xpra", "/eduke32/eduke32"]