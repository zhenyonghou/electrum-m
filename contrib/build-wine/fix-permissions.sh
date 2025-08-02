#!/bin/bash
#
# COMPREHENSIVE fix for ALL permission issues in make_win.sh
# Replaces ALL direct script execution with bash execution
#

set -e

echo "=========================================="
echo "COMPREHENSIVE SCRIPT PERMISSION FIXES"
echo "=========================================="

# 备份原始文件
cp make_win.sh make_win.sh.backup
echo "✓ Backup created: make_win.sh.backup"

echo ""
echo "Applying comprehensive script execution fixes..."

# 修复所有CONTRIB脚本调用
echo "1. Fixing CONTRIB script calls..."
sed -i 's|"$CONTRIB"/make_libsecp256k1\.sh|bash "$CONTRIB"/make_libsecp256k1.sh|g' make_win.sh
sed -i 's|"$CONTRIB"/make_libusb\.sh|bash "$CONTRIB"/make_libusb.sh|g' make_win.sh  
sed -i 's|"$CONTRIB"/make_zbar\.sh|bash "$CONTRIB"/make_zbar.sh|g' make_win.sh

# 修复本地脚本调用
echo "2. Fixing local script calls..."
sed -i 's|"$here/prepare-wine\.sh"|bash "$here/prepare-wine.sh"|g' make_win.sh
sed -i 's|"$here/build-electrum-git\.sh"|bash "$here/build-electrum-git.sh"|g' make_win.sh

# 修复任何其他可能的脚本调用模式
echo "3. Fixing any remaining script patterns..."
sed -i 's|\./\([^[:space:]]*\.sh\)|bash ./\1|g' make_win.sh
sed -i 's|\$here/\([^[:space:]]*\.sh\)|bash $here/\1|g' make_win.sh

# 特殊处理：build_tools_util.sh 是source调用，不需要修改
echo "4. Keeping source calls unchanged (build_tools_util.sh)..."
# 这个不需要修改，因为是 '. "$CONTRIB"/build_tools_util.sh' 用的是source

echo ""
echo "=========================================="
echo "VERIFICATION AND RESULTS"
echo "=========================================="

echo "✓ All script execution fixes applied to make_win.sh"

echo ""
echo "📋 Summary of changes made:"
diff make_win.sh.backup make_win.sh || echo "Files are identical (no changes needed)"

echo ""
echo "🔍 Verifying ALL script calls in patched make_win.sh:"
echo ""
echo "1. CONTRIB scripts (should all have 'bash' prefix):"
grep -n "CONTRIB.*\.sh" make_win.sh || echo "   No CONTRIB script calls found"

echo ""
echo "2. Local scripts (should all have 'bash' prefix):"
grep -n "here.*\.sh" make_win.sh || echo "   No local script calls found"

echo ""
echo "3. All remaining .sh references:"
grep -n "\.sh" make_win.sh | head -10

echo ""
echo "🎯 Critical lines that were problematic:"
echo "   Line ~49 (libsecp256k1):"
sed -n '48,50p' make_win.sh | cat -n
echo "   Line ~88 (prepare-wine):"
sed -n '87,89p' make_win.sh | cat -n
echo "   Line ~96 (build-electrum-git):"
sed -n '95,97p' make_win.sh | cat -n

echo ""
echo "✅ COMPREHENSIVE PERMISSION FIXES COMPLETE!"
echo "==========================================" 