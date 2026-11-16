#!/bin/bash
# diy-part1.sh - add third-party feeds (runs inside openwrt/ before feeds update)
#
# v12 (2026-11-15): PassWall2 feeds. PassWall2 is NOT in the official
# ImmortalWrt feeds, so both feeds below are required:
# - passwall2: luci-app-passwall2 itself
#   (new org: Openwrt-Passwall/openwrt-passwall2, was xiaorouji/openwrt-passwall2)
# - passwall_packages: its dependencies not in official feeds
#   (chinadns-ng, tcping, geoview, and the sing-box/xray helper packages)
#   https://github.com/xiaorouji/openwrt-passwall-packages.git;main
# The workflow then runs `./scripts/feeds update -a && ./scripts/feeds install -a`,
# so these feeds are picked up automatically. The grep guards make the
# script idempotent if it ever runs twice.
grep -q '^src-git passwall_packages ' feeds.conf.default || echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' >> feeds.conf.default
grep -q '^src-git passwall2 ' feeds.conf.default || echo 'src-git passwall2 https://github.com/Openwrt-Passwall/openwrt-passwall2.git;main' >> feeds.conf.default
