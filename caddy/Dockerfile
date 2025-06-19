# syntax=docker/dockerfile:1

# Stage 1: Builder
FROM dunglas/frankenphp:builder-php8.4-alpine AS builder

# Add only the missing extensions
RUN install-php-extensions \
    mysqli \
    pdo_mysql \
    intl

# Copy xcaddy from the official Caddy builder image
COPY --from=caddy:builder /usr/bin/xcaddy /usr/bin/xcaddy

# Build custom FrankenPHP binary with Caddy and your modules
RUN CGO_ENABLED=1 \
    XCADDY_SETCAP=1 \
    CGO_CFLAGS=$(php-config --includes) \
    CGO_LDFLAGS="$(php-config --ldflags) $(php-config --libs)" \
    xcaddy build \
        --output /usr/local/bin/frankenphp \
        --with github.com/dunglas/frankenphp=./ \
        --with github.com/dunglas/frankenphp/caddy=./caddy/ \
        --with github.com/dunglas/caddy-cbrotli \
        --with github.com/caddy-dns/ovh \
        --with github.com/hslatman/caddy-crowdsec-bouncer/http \
        --with github.com/mholt/caddy-dynamicdns \
        --with github.com/mholt/caddy-l4 \
        --with github.com/mietzen/caddy-dynamicdns-cmd-source

# Stage 2: Runtime
FROM dunglas/frankenphp:php8.4-alpine AS runner

# Add the same missing extensions to runtime
RUN install-php-extensions \
    mysqli \
    pdo_mysql \
    intl

# Replace the official FrankenPHP binary with your custom-built one
COPY --from=builder /usr/local/bin/frankenphp /usr/local/bin/frankenphp

# Expose ports
EXPOSE 80 443

# Default command
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
