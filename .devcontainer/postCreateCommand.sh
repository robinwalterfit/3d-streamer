#!/usr/bin/env bash

# Make sure to remove any artifacts
echo "Removing node_modules, .next and out directories..."
rm -rf .next/ node_modules/ out/

# Make sure the user can access the virtual store
# This is needed, because otherwise pnpm tries to create the virtual store in
# the current directory and this seems to fail in the devcontainer
echo "Setting up virtual store..."
sudo mkdir -p /var/cache/buildkit/
sudo chown -R $(id -u):$(id -g) /var/cache/buildkit/

# Now recreate the steps from Dockerfile:
echo "Fetch dependencies..."
pnpm fetch

echo "Install with development options..."
pnpm install --frozen-lockfile --prefer-offline
