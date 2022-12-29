# syntax=docker/dockerfile:1
# -----------------------> The dependencies image
FROM node:18.12.1-bullseye AS dependencies
# Environment variables
ARG BUILD_ARCH
ENV BUILD_ARCH=${BUILD_ARCH:-n/a}
ARG BUILD_OS
ENV BUILD_OS=${BUILD_OS:-n/a}
ARG BUILD_TIMESTAMP
ENV BUILD_TIMESTAMP=${BUILD_TIMESTAMP:-n/a}
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH:-n/a}
ARG NODE_ENV
ENV NODE_ENV=${NODE_ENV:-production}
ENV npm_config_cache=/var/cache/buildkit/npm
# PNPM uses npm config -> pnpm config is alias for npm config
ENV npm_config_store_dir=/var/cache/buildkit/pnpm-store
ARG VERSION
ENV VERSION=${VERSION:-latest}

# Labels for the image
LABEL me.robinwalter.3d-streamer.author="Robin Walter"
LABEL me.robinwalter.3d-streamer.author.email="hello@robinwalter.me"
LABEL me.robinwalter.3d-streamer.author.url="https://robinwalter.me"
LABEL me.robinwalter.3d-streamer.build.arch=$BUILD_ARCH
LABEL me.robinwalter.3d-streamer.build.os=$BUILD_OS
LABEL me.robinwalter.3d-streamer.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.3d-streamer.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.3d-streamer.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.3d-streamer.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.3d-streamer.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.3d-streamer.version=$VERSION

# Debian tries to optimize docker build performance by disabling the apt-get
# cache. This is not needed since the mount cache type is used and the cache
# will be handled by BUILDKIT.
RUN rm -f /etc/apt/apt.conf.d/docker-clean

# Install dumb-init to prevent Node.js apps from running as PID 1
RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        dumb-init; \
# Clean up apt lists files
    rm -rf /var/lib/apt/lists/*

# The project uses pnpm
RUN corepack enable

WORKDIR /usr/src

# pnpm fetch is used for dependency optimization in Docker images
# It only requires the pnpm-lock.yaml file to create a virtual store with all dependencies
COPY pnpm-lock.yaml /usr/src/

# Fetch dependencies from lockfile
RUN --mount=type=cache,target=$npm_config_store_dir \
    if [ "$NODE_ENV" = "production" ]; then \
        pnpm fetch --prod; \
    else \
        pnpm fetch; \
    fi

# -----------------------> The build image
FROM node:18.12.1-bullseye AS build
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
ENV NODE_ENV=${NODE_ENV:-production}
ENV npm_config_cache=/var/cache/buildkit/npm
# PNPM uses npm config -> pnpm config is alias for npm config
ENV npm_config_store_dir=/var/cache/buildkit/pnpm-store
ARG VERSION
ENV VERSION=${VERSION:-latest}

# Labels for the image
LABEL me.robinwalter.3d-streamer.author="Robin Walter"
LABEL me.robinwalter.3d-streamer.author.email="hello@robinwalter.me"
LABEL me.robinwalter.3d-streamer.author.url="https://robinwalter.me"
LABEL me.robinwalter.3d-streamer.build.arch=$BUILD_ARCH
LABEL me.robinwalter.3d-streamer.build.os=$BUILD_OS
LABEL me.robinwalter.3d-streamer.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.3d-streamer.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.3d-streamer.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.3d-streamer.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.3d-streamer.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.3d-streamer.version=$VERSION

# The project uses pnpm
RUN corepack enable

WORKDIR /usr/src

# Copy virtual store from dependencies stage
COPY --from=dependencies /usr/src/node_modules /usr/src/node_modules

# Generally needed by Node.js
COPY ./.npmrc /usr/src/
COPY ./package*.json /usr/src/
COPY ./pnpm-*.yaml /usr/src/
# Website: 3d-streamer - copy only the source code
COPY ./src /usr/src/src
COPY ./static /usr/src/static
COPY ./.env.$NODE_ENV.local /usr/src/.env.$NODE_ENV.local
COPY ./gatsby-*.js /usr/src/
COPY ./LICENSE /usr/src/
COPY ./README.md /usr/src/
COPY ./tailwind.config.js /usr/src/
COPY ./tsconfig.json /usr/src/

# Install dependencies (offline)
RUN --mount=type=cache,target=$npm_config_store_dir \
    if [ "$NODE_ENV" = "production" ]; then \
        pnpm install --frozen-lockfile --ignore-scripts --prefer-offline --prod; \
    else \
        pnpm install --frozen-lockfile --prefer-offline; \
    fi

# Build the app with secret environment variables
RUN pnpm run generate

# ---------> The export image
FROM scratch AS export
# Environment variables
ARG BUILD_ARCH
ENV BUILD_ARCH=${BUILD_ARCH:-n/a}
ARG BUILD_OS
ENV BUILD_OS=${BUILD_OS:-n/a}
ARG BUILD_TIMESTAMP
ENV BUILD_TIMESTAMP=${BUILD_TIMESTAMP:-n/a}
ARG COMMIT_HASH
ENV COMMIT_HASH=${COMMIT_HASH:-n/a}
ARG VERSION
ENV VERSION=${VERSION:-latest}

# Labels for the image
LABEL me.robinwalter.3d-streamer.author="Robin Walter"
LABEL me.robinwalter.3d-streamer.author.email="hello@robinwalter.me"
LABEL me.robinwalter.3d-streamer.author.url="https://robinwalter.me"
LABEL me.robinwalter.3d-streamer.build.arch=$BUILD_ARCH
LABEL me.robinwalter.3d-streamer.build.os=$BUILD_OS
LABEL me.robinwalter.3d-streamer.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.3d-streamer.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.3d-streamer.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.3d-streamer.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.3d-streamer.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.3d-streamer.version=$VERSION

COPY --from=build /usr/src/public /

# ----------------------------> The production image
FROM node:18.12.1-bullseye-slim AS production
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
ENV NODE_ENV=${NODE_ENV:-production}
ARG VERSION
ENV VERSION=${VERSION:-latest}

# User mapping - important for devcontainers
ARG USERNAME=gatsby
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Labels for the image
LABEL me.robinwalter.3d-streamer.author="Robin Walter"
LABEL me.robinwalter.3d-streamer.author.email="hello@robinwalter.me"
LABEL me.robinwalter.3d-streamer.author.url="https://robinwalter.me"
LABEL me.robinwalter.3d-streamer.build.arch=$BUILD_ARCH
LABEL me.robinwalter.3d-streamer.build.os=$BUILD_OS
LABEL me.robinwalter.3d-streamer.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.3d-streamer.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.3d-streamer.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.3d-streamer.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.3d-streamer.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.3d-streamer.version=$VERSION

# Node.js apps shouldn't be run as PID 1
COPY --from=dependencies /usr/bin/dumb-init /usr/bin/dumb-init

# Add non-root user
RUN groupadd -g $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

WORKDIR /usr/src

RUN chown $USERNAME:$USERNAME /usr/src

# Copy virtual store from dependencies stage
COPY --chown=$USERNAME:$USERNAME --from=dependencies /usr/src/node_modules /usr/src/node_modules

COPY --chown=$USERNAME:$USERNAME --from=build /usr/src/public /usr/src/public

USER $USERNAME

EXPOSE 8000
CMD [ "dumb-init", "npm", "run", "serve" ]

# -----------------------> The development image
FROM node:18.12.1-bullseye AS development
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
ENV NODE_ENV=${NODE_ENV:-development}
ARG VERSION
ENV VERSION=${VERSION:-dev}

# User mapping - important for devcontainers
ARG USERNAME=gatsby
ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Labels for the image
LABEL me.robinwalter.3d-streamer.author="Robin Walter"
LABEL me.robinwalter.3d-streamer.author.email="hello@robinwalter.me"
LABEL me.robinwalter.3d-streamer.author.url="https://robinwalter.me"
LABEL me.robinwalter.3d-streamer.build.arch=$BUILD_ARCH
LABEL me.robinwalter.3d-streamer.build.os=$BUILD_OS
LABEL me.robinwalter.3d-streamer.build.timestamp=$BUILD_TIMESTAMP
LABEL me.robinwalter.3d-streamer.commit-hash=$COMMIT_HASH
LABEL me.robinwalter.3d-streamer.copyright="Copyright © 2022 Robin Walter. All rights reserved."
LABEL me.robinwalter.3d-streamer.homepage="https://github.com/robinwalterfit/3d-streamer"
LABEL me.robinwalter.3d-streamer.license="SPDX-License-Identifier: MIT"
LABEL me.robinwalter.3d-streamer.version=$VERSION

# Node.js apps shouldn't be run as PID 1
COPY --from=dependencies /usr/bin/dumb-init /usr/bin/dumb-init

# The project uses pnpm
RUN corepack enable

# Add non-root user
RUN groupadd -g $USER_GID $USERNAME && \
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME; \
# Install sudo and add the non-root user to sudoers
    apt-get update && \
    apt-get install --no-install-recommends -y \
        sudo; \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME; \
# Clean up apt lists files
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src

RUN chown $USERNAME:$USERNAME /usr/src

COPY --chown=$USERNAME:$USERNAME --from=build /usr/src /usr/src

USER $USERNAME

EXPOSE 8000
EXPOSE 9229
CMD [ "dumb-init", "pnpm", "run", "start" ]