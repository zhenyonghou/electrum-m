#!/bin/bash
#
# GitHub Actions optimized build script
# Handles permissions and TTY issues specifically for CI environments
#

set -e

echo "===== GitHub Actions Windows Build Script ====="
echo "Current directory: $(pwd)"
echo "User: $(whoami)"
echo "UID: $(id -u), GID: $(id -g)"

PROJECT_ROOT="$(pwd)/../.."
CONTRIB_WINE="$(pwd)"

echo "Project root: $PROJECT_ROOT"
echo "Contrib wine: $CONTRIB_WINE"

# Clear dist directory
echo "Clearing dist directory..."
rm -rf "$CONTRIB_WINE/dist"
mkdir -p "$CONTRIB_WINE/dist"

# Set all necessary permissions
echo "Setting file permissions..."
chmod +x build.sh make_win.sh build-ci.sh 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

# Build Docker image
echo "Building Docker image..."
docker build --no-cache -t electrum-wine-builder-img .

# Run Docker container with explicit bash execution (no permission changes needed)
echo "Running Docker container..."
docker run \
    --name electrum-wine-builder-cont \
    -v "$PROJECT_ROOT":/opt/wine64/drive_c/electrum \
    --rm \
    --workdir /opt/wine64/drive_c/electrum/contrib/build-wine \
    electrum-wine-builder-img \
    bash -c "
        set -e
        echo 'Inside Docker container:'
        echo 'User: \$(whoami)'
        echo 'Working directory: \$(pwd)'
        echo 'Files in current directory:'
        ls -la
        
        echo 'File permissions check:'
        ls -la make_win.sh
        
        echo 'Applying permission fixes first...'
        bash fix-permissions.sh
        
        echo 'Starting patched make_win.sh with bash (no execute permission needed)...'
        bash make_win.sh
        
        echo 'Build completed, checking results:'
        ls -la dist/ 2>/dev/null || echo 'No dist directory found'
    "

echo "===== Build script completed ====="
echo "Results in dist directory:"
ls -la "$CONTRIB_WINE/dist/" 2>/dev/null || echo "No dist directory found" 