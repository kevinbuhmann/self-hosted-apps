FROM alpine:latest

ARG RESTIC_DOWNLOAD_URL=https://github.com/restic/restic/releases/download/v0.19.1/restic_0.19.1_linux_amd64.bz2
ARG RESTIC_DOWNLOAD_FILENAME=/tmp/restic_0.19.1_linux_amd64.bz2
ARG RESTIC_SHA256=f415415624dcc452f2a02b8c33641791a8c6d6d3b65bbb3543fcf9a25151585c

ARG RCLONE_DOWNLOAD_URL=https://github.com/rclone/rclone/releases/download/v1.75.2/rclone-v1.75.2-linux-amd64.zip
ARG RCLONE_DOWNLOAD_FILENAME=/tmp/rclone-v1.75.2-linux-amd64.zip
ARG RCLONE_SHA256=349ac8fba6ff65d6247043f1750cdcb518ec5d500ef91463a10d37c0ccdf3702

# install restic and rclone from GitHub releases
RUN apk add --no-cache curl \
    # install restic
    && curl -sL -o $RESTIC_DOWNLOAD_FILENAME "$RESTIC_DOWNLOAD_URL" \
    && echo "$RESTIC_SHA256 $RESTIC_DOWNLOAD_FILENAME" | sha256sum -c - \
    && bunzip2 $RESTIC_DOWNLOAD_FILENAME \
    && mv /tmp/restic* /usr/local/bin/restic \
    && chmod +x /usr/local/bin/restic \
    # install rclone
    && curl -sL -o $RCLONE_DOWNLOAD_FILENAME "$RCLONE_DOWNLOAD_URL" \
    && echo "$RCLONE_SHA256 $RCLONE_DOWNLOAD_FILENAME" | sha256sum -c - \
    && unzip $RCLONE_DOWNLOAD_FILENAME -d /tmp \
    && mv /tmp/rclone-*/rclone /usr/local/bin/rclone \
    && chmod +x /usr/local/bin/rclone \
    # clean up
    && rm -rf /tmp/* \
    && apk del curl
