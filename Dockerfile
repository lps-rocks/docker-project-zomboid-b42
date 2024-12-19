# Build from Debian 11 Slim image
FROM debian:bullseye-slim

# ENV Variables for installing server
ENV STEAM_APP=380870 \
    STEAM_AUTO_UPDATE=false \
    STEAM_INSTALL_PATH="/data" \
    SERVER_NAME="pzserver" \
    SERVER_ADDITIONAL_PARAMS="" \
    PUID=1000 \
    PGID=1000
# Stop apt-get asking to get Dialog frontend
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm

# Enable additional repositories
RUN sed -i -e's/ main$/ main contrib non-free/g' /etc/apt/sources.list

# Add i386 packages
RUN dpkg --add-architecture i386

# Preseed SteamCMD install
RUN echo steam steam/question select "I AGREE" | debconf-set-selections
RUN echo steam steam/license note '' | debconf-set-selections

# Install SteamCMD
RUN apt-get update && \
    apt-get -y install -y procps tmux locales sudo ca-certificates lib32gcc-s1 steamcmd && \
    apt-get clean

# Clean up APT
RUN rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \ 
    LC_ALL=en_US.UTF-8

# Add the steam user
RUN adduser \
    --disabled-login \
    --disabled-password \
    --shell /bin/bash \
    --gecos "" \
    steam && \
    usermod -G tty steam

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose Ports
EXPOSE 16261/udp
EXPOSE 16262/udp

# Expose Mounts
VOLUME ["/home/steam/Zomboid", "/home/steam/pzserver"]

# Working directory
WORKDIR /home/steam

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
