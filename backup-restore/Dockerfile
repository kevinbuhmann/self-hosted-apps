FROM alpine:3

ARG RESTIC_DOWNLOAD_URL=https://github.com/restic/restic/releases/download/v0.19.1/restic_0.19.1_linux_amd64.bz2
ARG RESTIC_DOWNLOAD_FILENAME=/tmp/restic_0.19.1_linux_amd64.bz2
ARG RESTIC_SHA256=f415415624dcc452f2a02b8c33641791a8c6d6d3b65bbb3543fcf9a25151585c

# install restic from GitHub releases
RUN apk add --no-cache curl \
    # install restic
    && curl -sL -o $RESTIC_DOWNLOAD_FILENAME "$RESTIC_DOWNLOAD_URL" \
    && echo "$RESTIC_SHA256 $RESTIC_DOWNLOAD_FILENAME" | sha256sum -c - \
    && bunzip2 $RESTIC_DOWNLOAD_FILENAME \
    && mv /tmp/restic* /usr/local/bin/restic \
    && chmod +x /usr/local/bin/restic \
    # clean up
    && rm -rf /tmp/* \
    && apk del curl
