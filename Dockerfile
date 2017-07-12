FROM alpine:latest

LABEL maintainer "docker@marcermarc.de"

# ---------------------
# Set Teamspeak Version
# ---------------------
ARG VERSION=3.0.13.7

# -------------------------------------
# Install glibc
# Download teamspeak
# Unpack teamspeak
# Create ts3server.ini for the sql-path
# Add user teamspeak
# -------------------------------------
RUN apk --no-cache add ca-certificates wget \
  && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub \
  && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk \
  && apk add glibc-2.25-r0.apk \
  && mkdir /tmp/ts /opt \
  && cd /tmp/ts \
  && wget http://dl.4players.de/ts/releases/${VERSION}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2 \
  && tar xjf teamspeak3-server_linux_amd64-${VERSION}.tar.bz2 -C /opt \
  && mv /opt/teamspeak3-server_* /opt/teamspeak \
  && rm -rf /tmp/ts \
  && apk --no-cache del ca-certificates wget \
  && echo dbsqlpath=/opt/teamspeak/sql/ > /opt/teamspeak/ts3server.ini \
  && adduser -h /opt/teamspeak -S -D teamspeak \
  && chown -R teamspeak /opt/teamspeak

# ------------
# Expose ports
# ------------
EXPOSE 9987/udp 30033/tcp 10011/tcp 2010/udp 41144/tcp 2008/tcp

# -------------
# Define volume
# -------------
VOLUME ["/mnt/teamspeak"]

# ----------------
# Set startup user
# ----------------
USER teamspeak

# -------------------------------
# Set the working directory
# At this path the data is stored
# -------------------------------
WORKDIR /mnt/teamspeak

# ----------------------------------------------------------
# This enviroment-variable is set by the minimal-startscript
# To start the server without the script it is set manual
# ----------------------------------------------------------
ENV LD_LIBRARY_PATH="/opt/teamspeak"

# ------------------------------------------
# Start the server with the created ini-file
# ------------------------------------------
ENTRYPOINT ["/opt/teamspeak/ts3server", "inifile=/opt/teamspeak/ts3server.ini"]
