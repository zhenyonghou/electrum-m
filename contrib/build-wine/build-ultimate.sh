#!/bin/bash
#
# ULTIMATE BUILD SCRIPT - Zero Permission Dependencies
# Executes everything with bash directly, no script permissions needed
#

set -e

echo "================================================"
echo "🚀 ULTIMATE WINDOWS BUILD SCRIPT"
echo "   Zero Permission Dependencies Solution"
echo "================================================"

PROJECT_ROOT="$(pwd)/../.."
echo "📂 Project root: $PROJECT_ROOT"

# Clean up
echo "🧹 Cleaning up previous builds..."
rm -rf dist/
mkdir -p dist/

# Build Docker image
echo "🏗️  Building Docker image..."
docker build -t electrum-wine-builder-img .

# Create an inline script that handles EVERYTHING with bash
echo "📝 Creating comprehensive inline build script..."

cat > /tmp/ultimate-build-script.sh << 'ULTIMATE_SCRIPT'
#!/bin/bash
set -ex

echo "=== ULTIMATE BUILD SCRIPT INSIDE CONTAINER ==="
echo "Current directory: $(pwd)"
echo "Current user: $(whoami || echo unknown)"
echo "Available files:"
ls -la

# Define all paths
CONTRIB="/opt/wine64/drive_c/electrum/contrib"
HERE="/opt/wine64/drive_c/electrum/contrib/build-wine"
CACHEDIR="$HERE/.cache/win64/build"
DLL_TARGET_DIR="$CACHEDIR/dlls"

# Set all environment variables that make_win.sh needs
export WIN_ARCH="win64"
export GCC_TRIPLET_HOST="x86_64-w64-mingw32"
export BUILD_TYPE="wine"
export GCC_TRIPLET_BUILD="x86_64-pc-linux-gnu"
export GCC_STRIP_BINARIES="1"
export PIP_CACHE_DIR="$HERE/.cache/win64/wine_pip_cache"
export WINE_PIP_CACHE_DIR="c:/electrum/contrib/build-wine/.cache/win64/wine_pip_cache"
export WINEPREFIX="/opt/wine64"
export WINEDEBUG=-all
export WINE_PYHOME="c:/python3"
export WINE_PYTHON="wine $WINE_PYHOME/python.exe -B"

# Source build tools (this is safe, it's just setting functions)
echo "Sourcing build tools..."
source "$CONTRIB/build_tools_util.sh"

# Create necessary directories
echo "Creating directories..."
mkdir -p "$CACHEDIR" "$DLL_TARGET_DIR" "$PIP_CACHE_DIR"

# Build libsecp256k1 - Execute with bash directly
echo "🔧 Building libsecp256k1..."
if ls "$DLL_TARGET_DIR"/libsecp256k1-*.dll 1> /dev/null 2>&1; then
    echo "libsecp256k1 already built, skipping"
else
    if [ -f "$CONTRIB/make_libsecp256k1.sh" ]; then
        bash "$CONTRIB/make_libsecp256k1.sh" || { echo "❌ Could not build libsecp"; exit 1; }
    else
        echo "❌ make_libsecp256k1.sh not found - this is required!"; exit 1
    fi
fi

# Build zbar - Execute with bash directly  
echo "🔧 Building zbar..."
if [ -f "$DLL_TARGET_DIR/libzbar-0.dll" ]; then
    echo "libzbar already built, skipping"
else
    if [ -f "$CONTRIB/make_zbar.sh" ]; then
        (
            cd "$CONTRIB"
            bash make_zbar.sh
        ) || { echo "❌ Could not build zbar"; exit 1; }
    else
        echo "⚠️  make_zbar.sh not found, skipping zbar build"
    fi
fi

# Build libusb - Execute with bash directly
echo "🔧 Building libusb..."
if [ -f "$DLL_TARGET_DIR/libusb-1.0.dll" ]; then
    echo "libusb already built, skipping"  
else
    if [ -f "$CONTRIB/make_libusb.sh" ]; then
        bash "$CONTRIB/make_libusb.sh" || { echo "❌ Could not build libusb"; exit 1; }
    else
        echo "⚠️  make_libusb.sh not found, skipping libusb build"
    fi
fi

# Prepare wine - Execute with bash directly
echo "🍷 Preparing Wine environment..."
if [ -f "$HERE/prepare-wine.sh" ]; then
    bash "$HERE/prepare-wine.sh" || { echo "❌ prepare-wine failed"; exit 1; }
else
    echo "❌ prepare-wine.sh not found - this is required!"; exit 1
fi

# Reset modification time in C:\Python
echo "⏰ Resetting modification time in C:\Python..."
pushd /opt/wine64/drive_c/python* || { echo "❌ Python directory not found"; exit 1; }
find -exec touch -h -d '2000-11-11T11:11:11+00:00' {} +
popd
ls -l /opt/wine64/drive_c/python*

# Build Electrum - Execute with bash directly
echo "⚡ Building Electrum..."
if [ -f "$HERE/build-electrum-git.sh" ]; then
    bash "$HERE/build-electrum-git.sh" || { echo "❌ build-electrum-git failed"; exit 1; }
else
    echo "❌ build-electrum-git.sh not found - this is required!"; exit 1
fi

echo "🎉 ULTIMATE BUILD COMPLETED SUCCESSFULLY!"
echo "Checking results:"
ls -la dist/ 2>/dev/null || echo "No dist directory found"
find . -name "*.exe" -o -name "*.zip" -o -name "*.msi" 2>/dev/null | head -5

ULTIMATE_SCRIPT

# Copy the script into the project for Docker to access
cp /tmp/ultimate-build-script.sh "$PROJECT_ROOT/contrib/build-wine/"

echo "🚀 Running ultimate build in Docker container..."
docker run \
    --rm \
    -v "$PROJECT_ROOT":/opt/wine64/drive_c/electrum \
    --workdir /opt/wine64/drive_c/electrum/contrib/build-wine \
    electrum-wine-builder-img \
    bash ultimate-build-script.sh

echo ""
echo "================================================"
echo "🎉 ULTIMATE BUILD COMPLETED!"
echo "================================================"
echo "📁 Results:"
find dist/ -type f 2>/dev/null || echo "No files in dist directory"

# Clean up temporary files
rm -f /tmp/ultimate-build-script.sh
rm -f "$PROJECT_ROOT/contrib/build-wine/ultimate-build-script.sh" 