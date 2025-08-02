#!/bin/bash
#
# Simplified build script for GitHub Actions
# Avoids all permission issues by using bash directly
#

set -e

echo "===== Simplified Windows Build Script ====="
echo "Working directory: $(pwd)"
echo "Available files:"
ls -la

# Build Docker image
echo "Building Docker image..."
docker build -t electrum-wine-builder-img .

# Simply run the container with bash, no permission concerns
echo "Running container with direct bash execution..."
docker run --rm \
    -v "$(pwd)/../..":/opt/wine64/drive_c/electrum \
    --workdir /opt/wine64/drive_c/electrum/contrib/build-wine \
    electrum-wine-builder-img \
    bash -c "bash fix-permissions.sh && bash make_win.sh"

echo "Build completed!"
echo "Checking for output files:"
find . -name "*.exe" -o -name "*.zip" -o -name "*.msi" 2>/dev/null || echo "No executables found yet" 