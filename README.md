# N60 Pro ImmortalWrt 24.10 官方旧版库（对照库 A）

# N60 Pro ImmortalWrt 云编译（GitHub Actions）

为磊科 N60 Pro（512MB / 128MB）定制的 ImmortalWrt 24.10 固件，基于官方 ImmortalWrt 源码（openwrt-24.10 分支）编译。

这是原 25.12 库的旧版官方对照库：内核 6.6、包管理 opkg（25.12 是 apk、内核 6.12）。
插件清单与 v13 完全一致（PassWall2+sing-box、AdGuardHome、Argon、DDNS、Attended Sysupgrade、nlbwmon、UPnP、WoL、Turbo ACC、eqos、IPTV、CPU 温度、ttyd、设备控制、watchcat、WireGuard、USB 扩容、BBR、中文包），只换底版，不改功能。
23.05 已 EoL，不用。SmartDNS/QoSmate/iStore 仍按 v4 决定不装（与 v13 一致，便于对照；24.10 上 opkg 时代它们本可装，如需再单独加）。

## 包含内容

- 基础：LuCI、防火墙、PPPoE、DHCP/DNS、IPv6、WiFi 驱动、USB、SSH
- 主题：Argon（默认主题，中文；官方源自带）
- 代理：PassWall2 + sing-box（v12 起替换 PassWall1，URLTest/leastPing 自动选优＋故障切换）
- 去广告：AdGuardHome
- DNS：AdGuardHome 过滤 + PassWall2 国内外分流（SmartDNS 已去掉，避免四层 DNS 串联）
- VPN：WireGuard（内置于网络接口）
- DDNS、Attended Sysupgrade（升级保留软件包）、nlbwmon、WoL、UPnP（用户要求增加，刷后在 服务 → UPnP 里启用）
- 加速：Turbo ACC（官方源；若无则自动跳过，内置硬件流量分载已能跑满千兆）+ BBR 拥塞控制（kmod-tcp-bbr）
- 限速：eqos（官方源，轻量按 IP 限速；QoSmate 已去掉，与硬件加速互斥）
- IPTV：igmpproxy + udpxy
- 监控：CPU 温度显示；网页终端 ttyd；设备上网控制；断网看门狗 watchcat
- USB 存储驱动：block-mount、kmod-usb-storage、kmod-usb-storage-uas、kmod-usb3、kmod-fs-ext4、e2fsprogs（128MB 闪存紧张时可插 U 盘扩容 /overlay；UAS 让 USB 3.0 跑满速，e2fsprogs 可在路由器上直接把 U 盘格成 ext4）
- 无线默认关闭（有线主路由）

## 使用方法

1. 在 GitHub 上新建一个仓库（Public，名字任意，如 `n60pro-immortalwrt`）
2. 把本目录里的全部文件上传到仓库根目录（保持目录结构，尤其是 `.github/workflows/build.yml`）
3. 打开仓库的 Actions 页面，点左侧 "Build ImmortalWrt N60 Pro"，点 "Run workflow"，确认
4. 等待编译完成（首次约 1–2 小时，GitHub 免费额度内）
5. 编译成功后，在该次运行的 Artifacts 里下载固件压缩包，解压得到 `immortalwrt-...-netcore_n60-pro-squashfs-sysupgrade.itb`
6. 用该 `.itb` 通过 LuCI「系统 → 备份/升级」或 sysupgrade 命令升级（不要用 U-Boot 网页恢复刷 `.itb`，那个只认特定格式；`.itb` 是给系统内升级用的）

## 注意事项

- 首次编译时间较长，请耐心等待；如果失败，点进失败的步骤看日志。
- Turbo ACC 走官方源，若官方源没有则自动跳过（内置硬件流量分载已能跑满千兆，不影响使用）。
- AdGuardHome 的中文语言包官方源没有，已在配置里列出 `luci-i18n-adguardhome-zh-cn`，有源提供就打进去，没有则自动跳过、AdGuardHome 用英文界面。
- v4 已去掉的包：iStore（依赖 opkg，在 25.12/apk 上不可靠；本库是 24.10/opkg，iStore 技术上可装，但按 v13 清单仍不装）、SmartDNS（与 AdGuardHome + PassWall 重复）、QoSmate（与硬件加速互斥）、luci-app-statistics（collectd + rrdtool 体积大，已有 nlbwmon）。如需这些功能，刷机后用 LuCI → 系统 → 软件包或 `opkg update && opkg install <包名>` 自行安装。
- v5 补充：USB 驱动加了 kmod-usb-storage-uas（UASP）和 e2fsprogs（mkfs.ext4）；删了 chenmozhijin 专属的 TURBOACC_INCLUDE_* 两行，改加官方 kmod-tcp-bbr。
- v8 补充：PassWall 默认的 Shadowsocks-Rust 子选项已关（它会在 aarch64 上默认拉起庞大的 Rust 工具链；sing-box 已原生支持 Shadowsocks，含 SS-2022）。diy-part2.sh 里仍保留 download-ci-llvm 改 false 的兜底（万一仍有包拉起 Rust，编译不会再因 CI 产物 404 失败）。
- v9 补充：PassWall 只留 sing-box 一个内核。PassWall 在 aarch64 上默认同时勾 xray-core 和 sing-box（各 25–35MB），128MB 闪存只留 sing-box；另关 PassWall 的 SmartDNS 子选项（它默认 y，会把 v4 删掉的 smartdns 又拉回来）。
- v10 补充：加 ccache（`CONFIG_CCACHE=y`＋工作流缓存 `~/.ccache`，上限 5G；首次编译仍慢，之后小改重编快得多）；补 LuCI 基础与防火墙中文包（`luci-i18n-base-zh-cn`、`luci-i18n-firewall-zh-cn`，否则主菜单仍显示英文）。
- v11 补充：补 `CONFIG_CCACHE_DIR="/home/runner/.ccache"`。OpenWrt 默认把缓存写进源码目录下的 `.ccache`，不指定就会和工作流缓存的 `~/.ccache` 对不上号、重编命中不了缓存；不加不影响本次编译和固件功能，只影响下次重编速度。
- v12 补充：PassWall1 换 PassWall2。①diy-part1.sh 加两个源：`passwall2`（Openwrt-Passwall/openwrt-passwall2，main）＋`passwall_packages`（xiaorouji/openwrt-passwall-packages，main，提供 chinadns-ng/tcping/geoview 等官方源没有的依赖）；PassWall2 不在官方源，不加这两个源编译会找不到包。②n60-pro.config 删 PassWall1 全套、只留 PassWall2（不双装：省闪存、避免两个透明代理打架）。③核心只留 sing-box（PassWall2 默认 All 会同时拉 xray-core＋sing-box，各 25–35MB，128MB 闪存放不下）；关 Haproxy（负载均衡走 sing-box urltest，不走 Haproxy）、关 Shadowsocks-Rust（会拉 Rust 工具链，即 #2 编译失败的 CI LLVM 404 根因；sing-box 已原生支持 SS/SS-2022）、关 SSR/Simple-Obfs/V2ray-Plugin（VLESS 节点用不上）。④刷机后节点须在 PassWall2 里重建：旧 `/etc/config/passwall` 不自动迁移到 `/etc/config/passwall2`，订阅链接重加最省事；刷前先备份节点（订阅链接/截图）和 LuCI 备份。⑤刷 v12 建议不保留设置（旧 PassWall/dnsmasq 配置残留会干扰），刷后重设 root 密码、再加 PassWall2 节点；LAN 不用重改了，见 v13。
- v13 补充：默认 LAN 改为 192.168.10.1/24（方案 B：光猫保持路由模式，N60 不拨号，原 192.168.1.1 与光猫 LAN 冲突）。改在 `files/etc/uci-defaults/99-n60pro-defaults` 里，首次启动时写 `network.lan.ipaddr='192.168.10.1'`；DHCP 沿用默认（起始 100、上限 150），客户端拿 192.168.10.100–249、网关 192.168.10.1。只影响新刷的固件首次启动，不改已在跑的路由器；刷 v13 不保留设置后直接用 http://192.168.10.1 进 LuCI。注意：U-Boot 网页恢复页仍是 192.168.1.1，那是 U-Boot 自己的地址，不受此改动影响，别混淆。
- v14 补充：工作流三个 action 升版去 Node 20 警告：`actions/checkout@v4→@v5`、`actions/cache@v4→@v5`、`actions/upload-artifact@v4→@v6`。注意 upload-artifact 不能只升到 v5——已按各 tag 的 action.yml 逐项核对 `runs.using`，v5 仍是 `node20`，只有 v6 起才是 `node24`；checkout v5、cache v5 均为 `node24`。只改 build.yml，固件配置不变；重编只是为了消警告，#4 的固件本身没问题，不必为此重刷。
- 后期直接装插件：可以。两种方式：① LuCI → 系统 → 软件包，搜官方源里的包安装；② SSH 上 `opkg update && opkg install <包名>`。前提是路由器已能上网（PPPoE 通）。官方源 24.10 的包都能这样装（opkg 时代）。
- 闪存提醒：N60 Pro 只有 128MB 闪存，sing-box（约 30MB）+ AdGuardHome（约 40MB）占了大头，刷机后 /overlay 剩余空间有限。后续更新 PassWall 规则库或 AdGuardHome 过滤列表时注意空间；空间紧张时可插 USB 3.0 U 盘扩容 /overlay（USB 驱动已编进固件）。
- 固件默认 LAN 为 192.168.10.1/24（v13 起），root 无密码（首次进 LuCI 后立即设密码），无线默认关闭。电脑须拿到 192.168.10.x 才能打开 http://192.168.10.1；之前设过固定 192.168.1.x 的先改回自动获取。
- 每次重新运行都会拉取最新源码和软件包，相当于升级到最新 25.12。

## 刷机格式说明（.itb 与 U-Boot）

- 编译产物是 `*-squashfs-sysupgrade.itb`（FIT 格式），用 LuCI 系统内升级刷入。
- 当前路由器上的 821KB 标准版 U-Boot 已验证能正常引导 `.itb`（之前官方 25.12.2 的 `.itb` 就是这么刷起来并正常进 LuCI 的），一般不需要换 U-Boot。
- 万一刷完重启卡住无法引导，再按住 Reset 键通电进 U-Boot 网页后台（192.168.1.1），换刷专用于 FIT 格式的 U-Boot 后重试。

## 文件说明

- `.github/workflows/build.yml`：GitHub Actions 工作流
- `n60-pro.config`：编译配置（目标机型 + 软件包清单）
- `diy-part1.sh`：第三方源（v12：passwall2＋passwall_packages，PassWall2 用；其余仍走官方源）
- `diy-part2.sh`：编译后处理（Rust 编译修复：把 download-ci-llvm 改为 false，防 CI 产物 404）
- `files/etc/uci-defaults/99-n60pro-defaults`：首次启动设置（默认 LAN 192.168.10.1、关无线、默认 Argon 主题、中文界面；已加 `uci -q` 容错）
