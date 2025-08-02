#!/bin/bash
#
# Fix permission issues in make_win.sh by replacing direct script execution with bash
#

set -e

echo "Fixing script execution permissions in make_win.sh..."

# 备份原始文件
cp make_win.sh make_win.sh.backup

# 修复make_libsecp256k1.sh调用
sed -i 's|"$CONTRIB"/make_libsecp256k1.sh|bash "$CONTRIB"/make_libsecp256k1.sh|g' make_win.sh

# 修复make_libusb.sh调用（如果存在）
sed -i 's|"$CONTRIB"/make_libusb.sh|bash "$CONTRIB"/make_libusb.sh|g' make_win.sh

# 修复make_zbar.sh调用（如果存在）
sed -i 's|"$CONTRIB"/make_zbar.sh|bash "$CONTRIB"/make_zbar.sh|g' make_win.sh

# 修复其他可能的脚本调用
sed -i 's|\./\([^[:space:]]*\.sh\)|bash ./\1|g' make_win.sh

echo "Script execution fixes applied to make_win.sh"
echo "Changes made:"
diff make_win.sh.backup make_win.sh || echo "No differences to show (diff returned non-zero)" 