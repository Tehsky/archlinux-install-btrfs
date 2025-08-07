# Arch Linux 自动安装脚本 (Btrfs + 多桌面环境选择)

这是一个全自动的 Arch Linux 安装脚本，支持多种桌面环境选择和 Btrfs 快照功能。

## 主要特性

- 🗂️ **Btrfs 文件系统**：使用 Btrfs 作为根文件系统，支持快照功能
- 🖥️ **多桌面环境**：支持 Hyprland、KDE、GNOME、XFCE、i3 等
- 📦 **USTC 镜像源**：使用中科大镜像源加速下载
- 🇨🇳 **ArchLinuxCN 源**：预配置 ArchLinuxCN 软件源
- 💾 **磁盘选择**：支持用户选择安装磁盘
- 📸 **自动快照**：集成 Snapper 自动快照管理
- 🎯 **精简安装**：每个桌面环境都是精简化配置

## 系统要求

- **启动模式**：支持 UEFI 和 Legacy BIOS（自动检测）
- **内存**：至少 2GB 内存（推荐 4GB）
- **存储**：至少 20GB 硬盘空间
- **网络**：安装过程需要网络连接

## 📁 项目结构

```
archlinux-install/
├── 📄 install-archlinux-btrfs.sh   # 主安装脚本
├── 📁 modules/                     # 功能模块
│   ├── 🔍 check-boot-mode.sh      # 启动模式检测
│   ├── 📶 wifi-helper.sh          # WiFi连接助手
│   ├── 🌐 check-hyprland-network.sh # Hyprland网络检查
│   ├── ⚙️ setup-hyprland-network.sh # Hyprland网络配置
│   └── 🔧 post-install-config.sh  # 安装后配置
└── 📖 README.md                   # 项目说明
```

## 🛠️ 模块说明

### 🔍 check-boot-mode.sh - 启动模式检测
检测当前系统的启动模式和硬件信息：
- UEFI/BIOS启动模式检测
- 系统架构和硬件信息
- 磁盘和分区建议
- 安装前的系统检查

### 📶 wifi-helper.sh - WiFi连接助手
简化WiFi连接的交互式工具：
- 扫描可用WiFi网络
- 交互式连接管理
- 保存的网络管理
- 网络状态检查

### 🌐 check-hyprland-network.sh - Hyprland网络检查
检查Hyprland桌面的网络支持：
- NetworkManager状态检查
- 网络applet安装验证
- 蓝牙支持检查
- 网络连接测试

### ⚙️ setup-hyprland-network.sh - Hyprland网络配置
配置Hyprland的完整网络支持：
- 安装网络管理组件
- 配置自启动项
- 设置Waybar网络模块
- 创建故障排除脚本

### 🔧 post-install-config.sh - 安装后配置
系统安装后的优化和配置：
- Pacman配置优化
- AUR助手安装
- 开发环境配置
- 系统性能调优

## 使用方法

### 1. 准备安装环境

1. 下载 Arch Linux ISO 并制作启动盘
2. 从 USB 启动进入 Arch Linux Live 环境
3. 连接网络：
   ```bash
   # 有线网络通常自动连接
   # 无线网络使用 iwctl 或 WiFi助手
   ./modules/wifi-helper.sh
   ```

### 2. 检查启动模式（推荐）

```bash
# 下载并运行启动模式检测
curl -O https://raw.githubusercontent.com/your-repo/archlinux-install/main/modules/check-boot-mode.sh
chmod +x check-boot-mode.sh
./check-boot-mode.sh
```

```bash
# 下载启动模式检测脚本
curl -O https://raw.githubusercontent.com/your-repo/archlinux-install-btrfs/main/check-boot-mode.sh
chmod +x check-boot-mode.sh

# 运行检测脚本
./check-boot-mode.sh
```

### 3. 下载并运行安装脚本

```bash
# 下载安装脚本
curl -O https://raw.githubusercontent.com/your-repo/archlinux-install-btrfs/main/install-archlinux-btrfs.sh

# 或者使用 wget
wget https://raw.githubusercontent.com/your-repo/archlinux-install-btrfs/main/install-archlinux-btrfs.sh

# 给脚本执行权限
chmod +x install-archlinux-btrfs.sh

# 运行安装脚本
./install-archlinux-btrfs.sh
```

### 3. 按照提示完成安装

脚本会提示您：
- 选择安装磁盘
- 设置用户名和密码
- 设置主机名
- **选择桌面环境**（Hyprland/KDE/GNOME/XFCE/i3/Minimal）
- 确认安装（会清空所选磁盘）

## 桌面环境选择

### 1. Hyprland (推荐)
- **类型**：现代 Wayland 合成器
- **特点**：流畅、美观、可定制
- **适合**：喜欢现代化界面的用户
- **包含**：Waybar、Wofi、Kitty、Thunar
- **网络支持**：NetworkManager + nm-applet (自动配置)

### 2. KDE Plasma (功能丰富)
- **类型**：完整桌面环境
- **特点**：功能强大、高度可定制
- **适合**：需要完整桌面功能的用户
- **包含**：Konsole、Dolphin、Kate (精简版)

### 3. GNOME (简洁现代)
- **类型**：现代桌面环境
- **特点**：简洁、易用、现代化
- **适合**：喜欢简洁界面的用户
- **包含**：GNOME Terminal、Nautilus (精简版)

### 4. XFCE (轻量级)
- **类型**：轻量级桌面环境
- **特点**：资源占用少、稳定
- **适合**：老旧硬件或追求性能的用户
- **包含**：基本桌面组件

### 5. i3 (高级用户)
- **类型**：平铺式窗口管理器
- **特点**：键盘驱动、高效
- **适合**：高级用户、程序员
- **包含**：i3status、dmenu、Alacritty

### 6. Minimal (无桌面)
- **类型**：纯命令行系统
- **特点**：最小化安装
- **适合**：服务器或自定义安装
- **包含**：仅基础系统组件

### 4. 安装后配置

重启进入新系统后，运行后配置脚本：

```bash
# 下载后配置脚本
curl -O https://raw.githubusercontent.com/your-repo/archlinux-install-btrfs/main/post-install-config.sh

# 给脚本执行权限
chmod +x post-install-config.sh

# 运行后配置脚本
./post-install-config.sh
```

### 5. 启动 Hyprland

```bash
# 启动 Hyprland
start-hyprland

# 或者直接运行
Hyprland
```

## 启动模式支持

脚本会自动检测启动模式并相应配置：

### UEFI 模式
- **分区表**：GPT
- **分区方案**：
  - EFI 分区 (512MB, FAT32) → `/boot`
  - 根分区 (剩余空间, Btrfs) → `/`
- **引导器**：GRUB (x86_64-efi)

### BIOS/Legacy 模式
- **分区表**：MBR
- **分区方案**：
  - 根分区 (全部空间, Btrfs) → `/`
- **引导器**：GRUB (i386-pc)

## Btrfs 子卷结构

脚本会创建以下 Btrfs 子卷：

```
/          -> @
/home      -> @home
/var       -> @var
/tmp       -> @tmp
/.snapshots -> @snapshots
```

## 快照管理

### 创建快照

```bash
# 创建快照（需要 root 权限）
sudo create-snapshot "描述信息"

# 例如
sudo create-snapshot "系统更新前"
sudo create-snapshot "安装新软件前"
```

### 查看快照

```bash
# 列出所有快照
sudo snapper -c root list

# 查看快照详情
sudo snapper -c root info <快照编号>
```

### 恢复快照

```bash
# 恢复到指定快照（谨慎操作）
sudo snapper -c root undochange <快照编号1>..<快照编号2>
```

## Hyprland 网络支持

### 自动配置的网络功能
- **NetworkManager**：自动安装和启用
- **nm-applet**：网络管理图形界面（系统托盘）
- **blueman**：蓝牙管理工具
- **Waybar 网络模块**：状态栏显示网络状态

### 网络管理
```bash
# 查看可用 WiFi 网络
nmcli device wifi list

# 连接 WiFi
nmcli device wifi connect "网络名称" password "密码"

# 查看网络状态
nmcli device status

# 查看已保存的连接
nmcli connection show
```

### WiFi 连接助手
```bash
# 下载 WiFi 助手脚本
curl -O https://raw.githubusercontent.com/your-repo/wifi-helper.sh
chmod +x wifi-helper.sh

# 交互式 WiFi 管理
./wifi-helper.sh

# 命令行使用
./wifi-helper.sh list                    # 列出网络
./wifi-helper.sh connect "WiFi名称" "密码"  # 连接网络
./wifi-helper.sh status                  # 查看状态
```

### 网络检测和修复
```bash
# 下载网络检测脚本
curl -O https://raw.githubusercontent.com/your-repo/check-hyprland-network.sh
chmod +x check-hyprland-network.sh

# 检测网络支持
./check-hyprland-network.sh

# 网络配置脚本（安装后运行）
curl -O https://raw.githubusercontent.com/your-repo/setup-hyprland-network.sh
chmod +x setup-hyprland-network.sh
./setup-hyprland-network.sh
```

### 故障排除
如果网络图标未显示或无法连接：
```bash
# 重启网络服务
sudo systemctl restart NetworkManager

# 手动启动网络图标
nm-applet --indicator &

# 重新扫描 WiFi
nmcli device wifi rescan
```

## Hyprland 快捷键

| 快捷键 | 功能 |
|--------|------|
| `Super + Q` | 打开终端 (Kitty) |
| `Super + C` | 关闭当前窗口 |
| `Super + M` | 退出 Hyprland |
| `Super + E` | 打开文件管理器 (Thunar) |
| `Super + R` | 打开应用启动器 (Wofi) |
| `Super + V` | 切换浮动模式 |
| `Super + 1-9` | 切换工作区 |
| `Super + Shift + 1-9` | 移动窗口到工作区 |
| `Super + 方向键` | 移动焦点 |
| `Super + Print` | 截图 |

## 包含的软件

### 系统工具
- `btrfs-progs` - Btrfs 工具
- `snapper` - 快照管理
- `grub` - 引导加载器
- `networkmanager` - 网络管理

### 桌面环境
- `hyprland` - Wayland 合成器
- `waybar` - 状态栏
- `wofi` - 应用启动器
- `kitty` - 终端模拟器
- `thunar` - 文件管理器

### 音频和媒体
- `pipewire` - 音频服务器
- `wireplumber` - 会话管理器
- `pamixer` - 音量控制
- `playerctl` - 媒体控制

### 输入法
- `fcitx5` - 输入法框架
- `fcitx5-chinese-addons` - 中文输入法

### 其他工具
- `firefox` - 网页浏览器
- `grim` + `slurp` - 截图工具
- `brightnessctl` - 亮度控制

## 故障排除

### 网络问题
```bash
# 检查网络状态
nmcli device status

# 连接 WiFi
nmcli device wifi connect "WiFi名称" password "密码"
```

### 音频问题
```bash
# 重启音频服务
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### 输入法问题
```bash
# 启动输入法
fcitx5 &

# 配置输入法
fcitx5-configtool
```

### 快照空间不足
```bash
# 清理旧快照
sudo snapper -c root delete <快照编号>

# 设置自动清理
sudo snapper -c root set-config TIMELINE_CLEANUP=yes
```

## 自定义配置

### Hyprland 配置
配置文件位置：`~/.config/hypr/hyprland.conf`

### Waybar 配置
配置文件位置：`~/.config/waybar/config` 和 `~/.config/waybar/style.css`

### Wofi 配置
配置文件位置：`~/.config/wofi/config` 和 `~/.config/wofi/style.css`

## 启动模式检测

脚本会自动检测并显示当前启动模式：

```bash
# 检查启动模式
ls /sys/firmware/efi/efivars  # 存在则为 UEFI，否则为 BIOS
```

### 启动模式切换
如需切换启动模式：
1. 进入 BIOS/UEFI 设置
2. 查找 "Boot Mode"、"UEFI/Legacy" 或类似选项
3. 选择所需模式并保存
4. 重新启动并重新制作启动盘

## 注意事项

1. **备份重要数据**：安装前请备份重要数据，脚本会完全清空选定的磁盘
2. **网络连接**：确保安装过程中网络连接稳定
3. **启动模式**：脚本自动支持 UEFI 和 BIOS 模式
4. **磁盘空间**：建议至少 20GB 空间用于系统安装
5. **Secure Boot**：如使用 UEFI，建议暂时禁用 Secure Boot

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
