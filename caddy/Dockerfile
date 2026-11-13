FROM caddy:2-builder AS builder

ARG CLOUDFLARE_API_URL=https://api.cloudflare.com/client/v4

# Clone and patch the libdns Cloudflare implementation.
RUN git clone https://github.com/libdns/cloudflare.git /tmp/libdns-cloudflare

RUN sed -i \
    's|https://api.cloudflare.com/client/v4|'"$CLOUDFLARE_API_URL"'|g' \
    /tmp/libdns-cloudflare/client.go

# Build Caddy, replacing the transitive libdns dependency.
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/libdns/cloudflare=/tmp/libdns-cloudflare

FROM caddy:2

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
