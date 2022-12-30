<p align="center">
    <a href="https://github.com/robinwalterfit/3d-streamer">
        <img src="https://github.com/robinwalterfit/3d-streamer/blob/main/src/assets/images/icon.png" height="128">
        <h1 align="center">3D-printing streamer</h1>
    </a>
</p>

<p align="center">
    <a aria-label="Commitizen friendly" href="https://commitizen.github.io/cz-cli/">
        <img alt="Commitizen friendly" src="https://img.shields.io/badge/commitizen-friendly-brightgreen.svg?style=for-the-badge">
    </a>
    <a aria-label="Open in Remote - Containers" href="https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/robinwalterfit/3d-streamer/tree/develop">
        <img alt="Open in Remote - Containers" src="https://img.shields.io/static/v1?label=Remote%20-%20Containers&message=Open&color=blue&logo=visualstudiocode&style=for-the-badge">
    </a>
</p>

3D-printing streamer is a small Next.js website to watch RTMP/HLS streams of
a custom RTMP/HLS server with nginx. This repository also provides a Dockerfile
based on [tiangolo/nginx-rtmp-docker](https://github.com/tiangolo/nginx-rtmp-docker)
for the nginx RTMP/HLS server.

## Installation / First steps

To get a local copy running all you need are Docker and Docker Compose:

```bash
docker compose up -d
```

To make sure the Docker images can be built successfully, you will need the
following environment variables in your `shell`:

```bash
export BUILD_ARCH=$(uname -m)
export BUILD_OS=$(uname)
export BUILD_TIMESTAMP=$(date +%s)
# Prevent "fatal: no git..."
if git -C . rev-parse 2> /dev/null; then
    export COMMIT_HASH=$(git log -n 1 --format=%H)
else
    export COMMIT_HASH="n/a"
fi
export USER_GID=$(id -g)
export USER_UID=$(id -u)
export USERNAME=$(id -un)
```

To prevent exporting these environment variables over and over again, being
able to use "Docker Compose Variable Substitution" and "VSCode Devcontainer
Variable Substitution", it is advisable to store those variables either in
`~/.bash_profile` or `~/.zshenv` (based on your login-shell).

Docker compose uses the `docker-compose.yml` file to build the Docker images
and starts the container in detached mode.

## Development

To extend 3D-printing streamer Docker is used, too. Using Docker and Docker
Compose simplifies the installation and setup of needed servers/tools (e.g.
Nginx with RTMP-module) and the development environment. Visual Studio Code is
the recommend code editor along with the official `Devcontainers` and `Docker`
extensions.

```bash
git clone git@github.com:robinwalterfit/3d-streamer.git
# or: gh repo clone robinwalterfit/3d-streamer
cd 3d-streamer/
code .
```

At first the repository will be cloned in your current directory. Alternatively
this can be done with the GitHub CLI. Then the directory is changed to the
cloned repository and VSCode will be started.

### Build project

The website can be independently built from the server.

#### Website

You need `Node.js` and `pnpm` or `Docker` installed.

```bash
pnpm install
pnpm generate
```

Or with Docker:

```bash
docker buildx build --build-arg BUILD_ARCH=$(uname -m) --build-arg BUILD_OS=$(uname) --build-arg BUILD_TIMESTAMP=$(date +%s) --build-arg COMMIT_HASH=$(git log -n 1 --format=%H) --build-arg NODE_ENV=production --build-arg USER_GID=$(id -g) --build-arg USER_UID=$(id -u) --build-arg USERNAME=$(id -un) --build-arg VERSION=$(cat package.json | grep -o '"version": "[^"]*' | grep -o '[^"]*$') -f docker/3d-streamer.Dockerfile -t robinwalterfit/3d-streamer:latest --target export -o - . > 3d-streamer_latest.tar
tar -xzf 3d-stramer_latest.tar -C ./public
rm 3d-streamer_latest.tar
```

No matter which way you choose, the built will live in the `/public` directory.

If you chose to build the website with Docker, the export stage of the
`Dockerfile` will be used. The website will be built as part of the Docker image
and then exported to an empty filesystem, which will be saved in a `tar` archive.
This archive will then be unpacked in the `/public` folder.

#### RTMP/HLS server

Use the following command to build the RTMP/HLS server image:

```bash
docker buildx build --build-arg BUILD_ARCH=$(uname -m) --build-arg BUILD_OS=$(uname) --build-arg BUILD_TIMESTAMP=$(date +%s) --build-arg COMMIT_HASH=$(git log -n 1 --format=%H) --build-arg NODE_ENV=production --build-arg USER_GID=$(id -g) --build-arg USER_UID=$(id -u) --build-arg USERNAME=$(id -un) --build-arg VERSION=$(cat package.json | grep -o '"version": "[^"]*' | grep -o '[^"]*$') -f docker/rtmp-server.Dockerfile -t robinwalterfit/rtmp-server:latest --target production .
```

## Features

-   Serve your own RTMP/HLS (and Dash) server via Docker (Compose)
-   Watch your streams on a custom website served by the same Nginx server

## Configuration

It's possible to customize the website via the `.env*` (dotenv) files. These can
be used to configure the project for different environments (`development`,
`test`, `production`, etc.).

## Links

-   Project Repository: [https://github.com/robinwalterfit/3d-streamer](https://github.com/robinwalterfit/3d-streamer)
-   Issues / Features: [https://github.com/robinwalterfit/3d-streamer/issues](https://github.com/robinwalterfit/3d-streamer/issues)
-   See also:
    -   Commitizen: [https://commitizen.github.io/cz-cli/](https://commitizen.github.io/cz-cli/)
    -   Commitlint: [https://commitlint.js.org/#/](https://commitlint.js.org/#/)
    -   Conventional Commits: [https://www.conventionalcommits.org/en/v1.0.0/](https://www.conventionalcommits.org/en/v1.0.0/)
    -   Cypress: [https://www.cypress.io/](https://www.cypress.io/)
    -   Docker: [https://www.docker.com/](https://www.docker.com/)
    -   Docker Compose: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
    -   EditorConfig: [https://editorconfig.org/](https://editorconfig.org/)
    -   ESLint: [https://eslint.org/](https://eslint.org/)
    -   GitHub: [https://github.com](https://github.com)
    -   Husky: [https://typicode.github.io/husky/#/](https://typicode.github.io/husky/#/)
    -   Lint staged: [https://github.com/okonet/lint-staged](https://github.com/okonet/lint-staged)
    -   Lodash: [https://lodash.com/](https://lodash.com/)
    -   Next.js: [https://nextjs.org/](https://nextjs.org/)
    -   Nginx [https://www.nginx.com/](https://www.nginx.com/)
    -   Nginx RTMP Docker: [https://github.com/tiangolo/nginx-rtmp-docker](https://github.com/tiangolo/nginx-rtmp-docker)
    -   Nginx RTMP module: [https://github.com/arut/nginx-rtmp-module](https://github.com/arut/nginx-rtmp-module)
    -   PNPM: [https://pnpm.io/](https://pnpm.io/)
    -   Prettier: [https://prettier.io/](https://prettier.io/)
    -   React.js: [https://reactjs.org/](https://reactjs.org/)
    -   Release Please: [https://github.com/googleapis/release-please](https://github.com/googleapis/release-please)
    -   tr&aelig;fik proxy: [https://traefik.io/traefik/](https://traefik.io/traefik/)
    -   Visual Studio Code: [https://code.visualstudio.com/](https://code.visualstudio.com/)

## License

Licensed under MIT. See [LICENSE](https://github.com/robinwalterfit/3d-streamer/blob/main/LICENSE)
for more information.
