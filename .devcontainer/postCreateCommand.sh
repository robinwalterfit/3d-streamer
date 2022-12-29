#!/usr/bin/env bash

# Make sure to clean the store. Since the store is virtual (symlinks)
# pnpm could crash. The devcontainer works with bind mounts.
echo "Prune pnpm store..."
pnpm store prune

# Now recreate the steps from Dockerfile:
echo "Fetch dependencies..."
pnpm fetch

echo "Install with development options..."
pnpm install --frozen-lockfile --prefer-offline
