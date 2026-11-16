#!/bin/bash
# diy-part2.sh - post-config tweaks (runs inside openwrt/ after .config is loaded)
# Wireless-off + Argon default theme + Chinese UI are set by
# files/etc/uci-defaults/99-n60pro-defaults on first boot.
#
# Rust host build fix (2026-11-15, build #2 failed on this):
# The host rustc (1.96.0) tries to download a prebuilt LLVM from Rust CI
# (`download-ci-llvm`), but that CI artifact URL returns 404, so the whole
# build fails with "ERROR: failed to download llvm from ci".
# Fix: force the Rust package to build LLVM from source instead.
# (Known upstream issue: https://github.com/immortalwrt/packages/issues/1854)
# Side effect: LLVM compiles from source, adding roughly 1 hour to the build.
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile
if grep -q 'ci-llvm=false' feeds/packages/lang/rust/Makefile; then
  echo "diy-part2: rust download-ci-llvm disabled"
else
  echo "diy-part2: WARNING: ci-llvm pattern not found in feeds/packages/lang/rust/Makefile"
fi
