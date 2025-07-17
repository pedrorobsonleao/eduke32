
# ----------------------
# Etapa 1: Build da aplicação
# ----------------------
FROM ubuntu:22.04 AS build

# Variáveis de ambiente para não interagir e definir timezone
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# Instala apenas dependências necessárias para build
RUN apt-get update -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
        build-essential \
        nasm \
        libgl1-mesa-dev \
        libsdl2-dev \
        flac \
        libflac-dev \
        libvpx-dev \
        libgtk2.0-dev \
        freepats \
        git \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Clona repositórios necessários
RUN git clone --depth=1 https://voidpoint.io/terminx/eduke32.git /tmp/eduke32 && \
    git clone --depth=1 https://github.com/ninjada/eduke32 /tmp/config_eduke32

# Compila o EDuke32
WORKDIR /tmp/eduke32
RUN make RELEASE=0

# Copia arquivos locais para build (se necessário)
COPY . /tmp/eduke32

# ----------------------
# Etapa 2: Imagem final minimalista
# ----------------------


# Use uma versão específica do Ubuntu para builds mais consistentes
FROM ubuntu:22.04 AS target

# Evita prompts interativos durante a instalação de pacotes
ARG DEBIAN_FRONTEND=noninteractive

# VOLUME para o socket X11
VOLUME /tmp/.X11-unix

# Instala dependências, os certificados CA e o Xpra
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        # Adicione ca-certificates aqui!
        ca-certificates \
        wget \
        gpg \
        xvfb \
        libsdl2-2.0-0 \
        flac \
        x11-xserver-utils \
        python3-pyinotify \
        python3-uinput \
#        lxterminal \
        xkb-data \
    # Baixa e importa a chave GPG do Xpra de forma segura
    && wget -O /tmp/xpra.asc https://xpra.org/gpg.asc \
    && gpg --dearmor -o /usr/share/keyrings/xpra-keyring.gpg /tmp/xpra.asc \
    && rm /tmp/xpra.asc \
    # Adiciona o repositório do Xpra
    && echo "deb [signed-by=/usr/share/keyrings/xpra-keyring.gpg] https://xpra.org/ jammy main" > /etc/apt/sources.list.d/xpra.list \
    # Atualiza e instala o Xpra
    && apt-get update \
    && apt-get install -y --no-install-recommends xpra xpra-x11 xpra-html5 \
    # Cria o diretório para o socket do Xpra (para o usuário root, UID 0)
    && mkdir -p /run/user/0/xpra \
    # Limpa o cache para reduzir o tamanho da imagem
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Define diretório de trabalho
WORKDIR /eduke32

# Copia binários e configs do build
COPY --from=build /tmp/eduke32/eduke32 .
COPY --from=build /tmp/eduke32/mapster32 .
COPY --from=build /tmp/config_eduke32 /root/.config/eduke32
#COPY --from=build /eduke32/.run_in_xpra /run_in_xpra

# Remove arquivos desnecessários e ajusta configurações
RUN rm -rf /root/.config/eduke32/EDuke32.app /root/.config/eduke32/.git && \
    sed -e 's/ScreenBPP = 32/ScreenBPP = 8/; s/ScreenHeight = 1200/ScreenHeight = 640/; s/ScreenWidth = 1920/ScreenWidth = 480/' -i /root/.config/eduke32/eduke32.cfg


# Expõe a porta
EXPOSE 8080

# Ponto de entrada
ENTRYPOINT ["xpra", "start", ":80", \
            "--no-daemon", \
            "--bind-tcp=0.0.0.0:8080", \
            "--html=on", \
            "--mdns=no", \
            "--notifications=no", \
            "--webcam=no", \
            "--start=/eduke32/eduke32"]