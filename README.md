# N60 Pro 官方 24.10 版 — ImmortalWrt 24.10

基于官方 ImmortalWrt 源码（openwrt-24.10 分支）的定制固件，面向磊科 N60 Pro（512MB 内存 / 128MB 闪存），有线主路由用途，无线默认关闭。

## 一、固件配置

### 底版

- ImmortalWrt 24.10，内核 6.6，包管理 opkg
- 官方 Turbo ACC（luci-app-turboacc）；硬件流量分载内置
- 标准 mac80211 无线驱动（已装，默认关闭）

### 当前构建

- #1：配置 47 个包，产物 74.4 MB，SHA256 `ad3cf1a835c0eb827e086d4e513faf04c5c9d07ce3e46146ee964a1479a95679`，构建 2h25m3s

### 默认设置

- LAN：192.168.10.1/24，DHCP 默认（客户端 192.168.10.100–249）
- 无线：默认关闭（radio0/radio1 均 disabled；开无线在 LuCI 里启用并设 SSID/密码）
- root：无密码，首次进 LuCI 后立即设置
- 时区：Asia/Shanghai（CST-8），NTP 为国内服务器
- LuCI：Argon 主题，简体中文

### 文件说明

- `.github/workflows/build.yml`：GitHub Actions 工作流（仅手动触发）
- `n60-pro.config`：编译配置（目标机型 + 软件包清单，47 个包）
- `diy-part1.sh`：第三方源（passwall2、passwall_packages）
- `diy-part2.sh`：编译后处理（Rust 编译修复）
- `files/etc/uci-defaults/99-n60pro-defaults`：首次启动设置（LAN 10.1、关无线、Argon、中文、时区）

## 二、功能效果

| 功能 | 插件与效果 |
|---|---|
| 代理 | PassWall2 + sing-box（只留 sing-box 内核）；HAProxy 未开，自动切换走 sing-box urltest |
| 去广告 | AdGuardHome（无 LuCI 界面，用其自带网页管理） |
| 远程访问 | WireGuard（luci-proto-wireguard + wireguard-tools） |
| 动态域名 | DDNS |
| 限速 | eqos（官方源）；QoSmate 未装（与硬件加速互斥） |
| 流量统计 | nlbwmon |
| 上网管控 | accesscontrol |
| IPTV | igmpproxy + udpxy |
| 端口转发 | UPnP（miniupnpd） |
| 唤醒 | WoL |
| 硬件加速 | Turbo ACC（官方源）+ BBR |
| 无线 | 标准驱动 + LuCI；默认关闭 |
| USB 存储 | block-mount、usb-storage(-uas)、usb3、ext4、e2fsprogs |
| 网页终端 | ttyd |
| 断网自愈 | watchcat |
| 升级 | attendedsysupgrade |

未包含：SmartDNS、QoSmate、iStore、luci-app-statistics、Samba / Transmission（NAS 已有）、OpenClash / Nikki / HomeProxy（代理核心只留 PassWall2）。

效果说明：

- 去广告只留 AdGuardHome（DoH/DoT、查询日志、按客户端统计）。
- PassWall2 自动切换走 sing-box urltest（HAProxy 未开）。
- Turbo ACC 走官方源；若官方源没有则自动跳过，内置硬件流量分载已能跑满千兆。

## 三、使用方法

### 刷机

产物是 `*-squashfs-sysupgrade.itb`（FIT 格式），用 LuCI 系统内升级刷入；不要用 U-Boot 网页恢复刷 `.itb`。

刷机前备份节点（订阅链接/截图）与 LuCI 备份：旧 PassWall 配置不会自动迁移到 PassWall2，节点须重建；建议不保留设置。

### 刷后检查

1. 设管理员密码。
2. 确认无线两个射频均为禁用。
3. AdGuardHome 用其自带网页管理。
4. PassWall2 自动切换：sing-box urltest 分组。
5. 测硬件加速是否绕过 PassWall2 与 AdGuardHome。

### 注意事项

- 128MB 闪存：sing-box 约 30MB、AdGuardHome 约 40MB，/overlay 余量有限；空间紧张时插 USB 3.0 U 盘扩容 /overlay（USB 驱动已编进固件）。
- 每次重新运行都会拉取最新源码和软件包，相当于升级到最新 24.10。

## 四、配置调整变更历史

### 修订记录

| 时间 | 版本 | 变更内容 |
|---|---|---|
| 2026-11-16 08:39 | 建库 | 仓库建立，6 个文件齐全 |
| 2026-11-16 11:47 | 构建 #1 | 首次编成（配置 47 个包，产物 74.4 MB，SHA256 `ad3cf1a8…`） |
| 2026-11-19 00:05 | 构建 #1（未重编） | README 按四类口径重写并增加修订记录（本条） |
