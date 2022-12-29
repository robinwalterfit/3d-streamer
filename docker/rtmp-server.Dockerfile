# syntax=docker/dockerfile:1
# -----------------------> The web-dependencies image
FROM node:18.12.1-bullseye AS web-dependencies
# Environment variables
ARG BUILD_ARCH
ENV BUILD_ARCH=${BUILD_ARCH:-n/a}
ARG BUILD_OS
ENV BUILD_OS=${BUILD_OS:-n/a}
ARG BUILD_TIMESTAMP
ENV BUILD_TIMESTAMP=${BUILD_TIMESTAMP:-n/a}
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH:-n/a}
ENV NODE_ENV=production
ENV npm_config_cache=/var/cache/buildkit/npm
# PNPM uses npm config -> pnpm config is alias for npm config
ENV npm_config_store_dir=/var/cache/buildkit/pnpm-store
ARG VERSION
ENV VERSION=${VERSION:-latest}

# Labels for the image
LABEL me.robinwalter.rtmp-server.author="Robin Walter"
LABEL me.robinwalter.rtmp-server.author.email="hello@robinwalter.me"
LABEL me.robinwalter.rtmp-server.author.url="https://robinwalter.me"
LABEL me.robinwalter.rtmp-server.build.arch=$BUILD_ARCH
LABEL me.robinwalter.rtmp-server.build.os=$BUILD_OS
LABEL me.robinwalter.rtmp-server.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.rtmp-server.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.rtmp-server.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.rtmp-server.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.rtmp-server.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.rtmp-server.version=$VERSION

# The project uses pnpm
RUN corepack enable

RUN mkdir -p /tmp/web

WORKDIR /tmp/web

# pnpm fetch is used for dependency optimization in Docker images
# It only requires the pnpm-lock.yaml file to create a virtual store with all dependencies
COPY ./pnpm-lock.yaml /tmp/web/

# Fetch dependencies from lockfile
RUN --mount=type=cache,target=$npm_config_store_dir \
    pnpm fetch --prod

# -----------------------> The web-build image
FROM node:18.12.1-bullseye AS web-build
# Environment variables
ARG BUILD_ARCH
ENV BUILD_ARCH=${BUILD_ARCH:-n/a}
ARG BUILD_OS
ENV BUILD_OS=${BUILD_OS:-n/a}
ARG BUILD_TIMESTAMP
ENV BUILD_TIMESTAMP=${BUILD_TIMESTAMP:-n/a}
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH:-n/a}
ENV GATSBY_TELEMETRY_DISABLED=1
ARG NODE_ENV
ENV NODE_ENV=production
ENV npm_config_cache=/var/cache/buildkit/npm
# PNPM uses npm config -> pnpm config is alias for npm config
ENV npm_config_store_dir=/var/cache/buildkit/pnpm-store
ARG VERSION
ENV VERSION=${VERSION:-latest}

# Labels for the image
LABEL me.robinwalter.rtmp-server.author="Robin Walter"
LABEL me.robinwalter.rtmp-server.author.email="hello@robinwalter.me"
LABEL me.robinwalter.rtmp-server.author.url="https://robinwalter.me"
LABEL me.robinwalter.rtmp-server.build.arch=$BUILD_ARCH
LABEL me.robinwalter.rtmp-server.build.os=$BUILD_OS
LABEL me.robinwalter.rtmp-server.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.rtmp-server.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.rtmp-server.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.rtmp-server.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.rtmp-server.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.rtmp-server.version=$VERSION

# The project uses pnpm
RUN corepack enable

RUN mkdir -p /tmp/web

WORKDIR /tmp/web

# Copy virtual store from web-dependencies stage
COPY --from=web-dependencies /tmp/web/node_modules /tmp/web/node_modules

# Generally needed by Node.js
COPY ./.npmrc /tmp/web/
COPY ./package*.json /tmp/web/
COPY ./pnpm-*.yaml /tmp/web/
# Website: 3d-streamer - copy only the source code
COPY ./src /tmp/web/src
COPY ./static /tmp/web/static
COPY ./.env.production.local /tmp/web/.env.production.local
COPY ./gatsby-*.js /tmp/web/
COPY ./LICENSE /tmp/web/LICENSE
COPY ./README.md /tmp/web/README.md
COPY ./tailwind.config.js /tmp/web/tailwind.config.js
COPY ./tsconfig.json /tmp/web/tsconfig.json

# Install dependencies (offline)
RUN --mount=type=cache,target=$npm_config_store_dir \
    pnpm install --frozen-lockfile --ignore-scripts --prefer-offline --prod

# Build the app with secret environment variables
RUN pnpm run generate

# -------------------------> The RTMP/HLS server image
FROM buildpack-deps:bullseye
# Environment variables
ARG BUILD_ARCH
ENV BUILD_ARCH=${BUILD_ARCH:-n/a}
ARG BUILD_OS
ENV BUILD_OS=${BUILD_OS:-n/a}
ARG BUILD_TIMESTAMP
ENV BUILD_TIMESTAMP=${BUILD_TIMESTAMP:-n/a}
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH:-n/a}
# Versions of Nginx and nginx-rtmp-module to use
ARG NGINX_RTMP_MODULE_VERSION
ENV NGINX_RTMP_MODULE_VERSION=${NGINX_RTMP_MODULE_VERSION:-1.2.2}
ARG NGINX_VERSION
ENV NGINX_VERSION=${NGINX_VERSION:-nginx-1.23.3}
ARG VERSION
ENV VERSION=${VERSION:-latest}

# Labels for the image
# Based on: https://github.com/tiangolo/nginx-rtmp-docker
# LABEL maintainer="Sebastian Ramirez <tiangolo@gmail.com>"
LABEL me.robinwalter.rtmp-server.author="Robin Walter"
LABEL me.robinwalter.rtmp-server.author.email="hello@robinwalter.me"
LABEL me.robinwalter.rtmp-server.author.url="https://robinwalter.me"
LABEL me.robinwalter.rtmp-server.build.arch=$BUILD_ARCH
LABEL me.robinwalter.rtmp-server.build.os=$BUILD_OS
LABEL me.robinwalter.rtmp-server.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.rtmp-server.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.rtmp-server.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.rtmp-server.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.rtmp-server.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.rtmp-server.version=$VERSION

# Debian tries to optimize docker build performance by disabling the apt-get
# cache. This is not needed since the mount cache type is used and the cache
# will be handled by BUILDKIT.
RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Install dependencies
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        ca-certificates \
        openssl \
        libssl-dev; \
# Clean up apt lists files
    rm -rf /var/lib/apt/lists/*

# Download and decompress Nginx
RUN mkdir -p /tmp/build/nginx && \
    cd /tmp/build/nginx && \
    wget -O $NGINX_VERSION.tar.gz https://nginx.org/download/$NGINX_VERSION.tar.gz && \
    tar -zxf $NGINX_VERSION.tar.gz

# Download and decompress RTMP module
RUN mkdir -p /tmp/build/nginx-rtmp-module && \
    cd /tmp/build/nginx-rtmp-module && \
    wget -O nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION.tar.gz https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_MODULE_VERSION.tar.gz && \
    tar -zxf nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION.tar.gz && \
    cd nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION

# Build and install Nginx
# The default puts everything under /usr/local/nginx, so it's needed to change
# it explicitly. Not just for order but to have it in the PATH
RUN cd /tmp/build/nginx/$NGINX_VERSION && \
    ./configure \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/lock/nginx/nginx.lock \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/tmp/nginx-client-body \
        --with-http_ssl_module \
        --with-threads \
        --with-ipv6 \
        --add-module=/tmp/build/nginx-rtmp-module/nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION --with-debug && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install && \
    mkdir /var/lock/nginx && \
    cp /tmp/build/nginx-rtmp-module/nginx-rtmp-module-1.2.2/stat.xsl /etc/nginx/stat.xsl && \
    rm -rf /tmp/build

# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Stream root path
RUN mkdir /nginx

# Copy website to watch HLS-streams
RUN rm /usr/local/nginx/html/index.html
COPY --from=web-build /tmp/web/public /usr/local/nginx/html

# Set up config file
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 1935
CMD ["nginx", "-g", "daemon off;"]