#!/bin/bash
#
# Debug script to check all permissions and fixes
#

echo "===== PERMISSION DEBUG INFORMATION ====="
echo "Current working directory: $(pwd)"
echo "Current user: $(whoami)"
echo "Current UID: $(id -u)"
echo "Current GID: $(id -g)"

echo ""
echo "===== SCRIPT FILES IN CURRENT DIRECTORY ====="
ls -la *.sh

echo ""
echo "===== CRITICAL BUILD SCRIPTS ====="
ls -la ../make_libsecp256k1.sh 2>/dev/null || echo "make_libsecp256k1.sh not found"
ls -la ../make_libusb.sh 2>/dev/null || echo "make_libusb.sh not found" 
ls -la ../make_zbar.sh 2>/dev/null || echo "make_zbar.sh not found"
ls -la ../build_tools_util.sh 2>/dev/null || echo "build_tools_util.sh not found"

echo ""
echo "===== CHECKING make_win.sh CONTENT ====="
echo "Lines around libsecp256k1 call (should show 'bash' prefix):"
grep -n -A2 -B2 "make_libsecp256k1.sh" make_win.sh || echo "No libsecp256k1 references found"

echo ""
echo "===== ALL SCRIPT REFERENCES IN make_win.sh ====="
grep -n "\.sh" make_win.sh | head -10

echo ""
echo "===== ENVIRONMENT VARIABLES ====="
echo "CONTRIB=$CONTRIB"
echo "DLL_TARGET_DIR=$DLL_TARGET_DIR"

echo ""
echo "===== END DEBUG INFORMATION =====" 