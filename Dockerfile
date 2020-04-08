# To use this Docker image, make sure you set up the mounts properly.
#
# The Minecraft server files are expected at
#     /home/minecraft/server
#
# The Minecraft-Overviewer render will be output at
#     /home/minecraft/render

FROM debian:stretch

LABEL MAINTAINER = 'Mark Ide Jr (https://www.mide.io)'

# Default to do both render Map + POI
ENV RENDER_MAP true
ENV RENDER_POI true

# Only render signs including this string, leave blank to render all signs
ENV RENDER_SIGNS_FILTER "-- RENDER --"

# Hide the filter string from the render
ENV RENDER_SIGNS_HIDE_FILTER "false"

# What to join the lines of the sign with when rendering POI
ENV RENDER_SIGNS_JOINER "<br />"

ENV CONFIG_LOCATION /home/minecraft/config.py

# Docs for rcon-cli here: https://github.com/itzg/rcon-cli
ENV RCON_ARGS_PRE ""
ENV RCON_ARGS_POST ""

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget gnupg optipng ca-certificates && \
    echo "deb http://overviewer.org/debian ./" >> /etc/apt/sources.list && \
    wget -O - https://overviewer.org/debian/overviewer.gpg.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y --no-install-recommends minecraft-overviewer && \
    useradd -m minecraft && \
    mkdir -p /home/minecraft/render /home/minecraft/server

# Install rcon-cli
RUN wget "https://github.com/itzg/rcon-cli/releases/download/1.4.7/rcon-cli_1.4.7_linux_amd64.tar.gz" -O /tmp/rcon-cli.tgz && \
    tar -xf /tmp/rcon-cli.tgz -C /usr/local/bin rcon-cli && \
    rm /tmp/rcon-cli.tgz

COPY config/config.py /home/minecraft/config.py
COPY entrypoint.sh /home/minecraft/entrypoint.sh
COPY download_url.py /home/minecraft/download_url.py

RUN chown minecraft:minecraft -R /home/minecraft/

WORKDIR /home/minecraft/

USER minecraft

CMD ["bash", "/home/minecraft/entrypoint.sh"]
