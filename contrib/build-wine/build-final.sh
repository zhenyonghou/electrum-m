#!/bin/bash
#
# Final build script - handles all permission and user ID issues
#

set -e

echo "===== Final Build Script for GitHub Actions ====="
echo "Host environment info:"
echo "  Current user: $(whoami)"
echo "  User ID: $(id -u)"
echo "  Group ID: $(id -g)"
echo "  Working directory: $(pwd)"

PROJECT_ROOT="$(pwd)/../.."

# Clean up any previous builds
echo "Cleaning up previous builds..."
rm -rf dist/
mkdir -p dist/

# Get current user ID for Docker user mapping
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)

echo "Building Docker image with UID=$CURRENT_UID..."
docker build --build-arg UID=$CURRENT_UID -t electrum-wine-builder-img .

# Run Docker with proper user mapping and environment
echo "Running Docker container with user mapping..."
docker run \
    --rm \
    --user "$CURRENT_UID:$CURRENT_GID" \
    -v "$PROJECT_ROOT":/opt/wine64/drive_c/electrum \
    --workdir /opt/wine64/drive_c/electrum/contrib/build-wine \
    -e HOME=/tmp \
    electrum-wine-builder-img \
    bash -c "
        set -e
        echo 'Container environment:'
        echo '  User: \$(whoami || echo unknown)'
        echo '  UID: \$(id -u)'
        echo '  GID: \$(id -g)'
        echo '  Working dir: \$(pwd)'
        echo '  Home: \$HOME'
        
        echo 'Files in working directory:'
        ls -la
        
        echo 'Running make_win.sh...'
        bash make_win.sh
    "

echo "Build completed!"
echo "Output files:"
find dist/ -type f 2>/dev/null || echo "No files in dist/ directory" 