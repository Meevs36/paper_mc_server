# Author -- meevs
# Creation Date -- 2023-03-11
# File Name -- Dockerfile
# Notes --

# Server
# ----------
FROM alpine AS paper_mc_server

ARG USER="paper"

# Minecraft / PaperMC arguments
ARG MC_VERSION="1.20.1"
ARG JAVA_VERSION="17"
# No PAPER_BUILD is assumed to be the latest build
ARG PAPER_BUILD=""
ARG CONFIG_DIR="config_files/latest"
ARG SERVER_CONFIG="server.properties"

# File system arguments
ARG INSTALL_DIR="/home/${USER}/server"

# Environment variables
# Java control variables
ENV JAVA_VERSION="${JAVA_VERSION}"
ENV MIN_RAM="2G"
ENV MAX_RAM="4G"

# Minecraft / PaperMC variables
ENV MC_VERSION="${MC_VERSION}"
ENV PAPER_BUILD="${PAPER_BUILD}"
ENV MC_EULA="false"

# File system variables
ENV INSTALL_DIR="${INSTALL_DIR}"
ENV BUILD_DIR="/tmp/paper_mc/build"

RUN apk add --no-cache openjdk${JAVA_VERSION}-jre bash curl jq \
	&& adduser -D ${USER}\
	&& mkdir --parent "${INSTALL_DIR}"\
	&& chown --recursive "${USER}:${USER}" "${INSTALL_DIR}"

COPY --chown="${USER}:${USER}" ./init_scripts/init_container.sh /usr/bin/init_script.sh


USER ${USER}

WORKDIR ${INSTALL_DIR}
RUN mkdir --parent "${BUILD_DIR}"\
	&& mkdir --parent "${INSTALL_DIR}/plugins"

COPY --chown="${USER}:${USER}" ./init_scripts/start_server.sh /tmp/paper_mc/start_server.sh
COPY --chown="${USER}:${USER}" "${CONFIG_DIR}/${SERVER_CONFIG}" "${INSTALL_DIR}/server.properties"
COPY --chown="${USER}:${USER}" "${CONFIG_DIR}/plugins/" "${INSTALL_DIR}/plugins/"

# Ensure execute bit is indeed set
RUN chmod u+x "/usr/bin/init_script.sh" "/tmp/paper_mc/start_server.sh"

CMD [ "/bin/bash", "-c" ]
ENTRYPOINT [ "/usr/bin/init_script.sh" ]

