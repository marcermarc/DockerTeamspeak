######################
# Downlaod Teamspeak #
######################
FROM alpine as download

# --------------
# Define version
# --------------
ARG VERSION=3.10.2

# --------------------------------------------
# Download teamspeak
# Unpack teamspeak
# Move the maria-db libary to the right folder
# Remove unnecessary files
# --------------------------------------------
RUN apk --update --no-cache add curl \
  && mkdir /tmp/ts \
  && curl -o /tmp/ts/ts.tar.bz2 http://files.teamspeak-services.com/releases/server/${VERSION}/teamspeak3-server_linux_alpine-${VERSION}.tar.bz2 \
  && tar xjf /tmp/ts/ts.tar.bz2 -C /opt \
  && mv /opt/teamspeak3-server_* /opt/teamspeak \
  && mv /opt/teamspeak/redist/* /opt/teamspeak \
  && rm -r /opt/teamspeak/doc \
	   /opt/teamspeak/serverquerydocs \
	   /opt/teamspeak/tsdns \
           /opt/teamspeak/redist \
	   /opt/teamspeak/CHANGELOG \
	   /opt/teamspeak/LICENSE* \
           /opt/teamspeak/*.sh

#######
# Run #
#######
FROM alpine

LABEL maintainer "docker@marcermarc.de"

# ----------------------------------
# Copy files from the download image
# ----------------------------------
COPY --from=download /opt/teamspeak /opt/teamspeak/

# -------------------------------------
# Add user teamspeak
# -------------------------------------
RUN apk --update --no-cache add libstdc++ ca-certificates \
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
ENTRYPOINT ["/opt/teamspeak/ts3server", "dbsqlpath=/opt/teamspeak/sql/", "license_accepted=1"]
