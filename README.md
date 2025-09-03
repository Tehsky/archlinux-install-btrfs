# 🐧 Arch Linux 自动安装脚本

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Arch Linux](https://img.shields.io/badge/Arch-Linux-blue.svg)](https://archlinux.org/)

一个功能完整的 Arch Linux 自动化安装脚本，支持 Btrfs 文件系统、多桌面环境选择和完整的系统配置。

## ✨ 主要特性

### 🚀 核心功能
- 🗂️ **Btrfs 文件系统** - 现代文件系统，支持快照和子卷
- 🖥️ **多桌面环境** - Hyprland、KDE、GNOME、XFCE、i3、Minimal
- 🔧 **自动检测** - UEFI/BIOS 启动模式自动识别
- 💾 **智能分区** - 用户友好的磁盘选择和自动分区

### 🌐 网络优化
- 📦 **USTC 镜像源** - 中科大镜像源加速下载
- 🇨🇳 **ArchLinuxCN 源** - 预配置中文社区软件源
- 📶 **网络工具** - 完整的 WiFi 和蓝牙支持

### 📸 系统管理
- 🔄 **自动快照** - 集成 Snapper 快照管理
- ⚡ **性能优化** - SSD 优化、内存管理
- 🛡️ **安全配置** - 防火墙、用户权限配置

## 📋 系统要求

| 项目 | 最低要求 | 推荐配置 |
|------|----------|----------|
| **启动模式** | UEFI/Legacy BIOS | UEFI |
| **内存** | 2GB RAM | 4GB+ RAM |
| **存储** | 20GB 硬盘空间 | 50GB+ SSD |
| **网络** | 有线/无线连接 | 稳定网络连接 |

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

## 🎯 支持的桌面环境

| 桌面环境 | 类型 | 特点 | 推荐用途 |
|----------|------|------|----------|
| **Hyprland** | Wayland 合成器 | 现代化、高性能 | 高级用户、开发者 |
| **KDE Plasma** | 完整桌面 | 功能丰富、可定制 | 日常使用、办公 |
| **GNOME** | 现代桌面 | 简洁、易用 | 新手用户 |
| **XFCE** | 轻量桌面 | 资源占用低 | 老旧硬件 |
| **i3** | 平铺窗口管理器 | 键盘操作、高效 | 程序员、极客 |
| **Minimal** | 无桌面环境 | 最小安装 | 服务器、自定义 |

## 🛠️ 功能模块详解

<details>
<summary>🔍 <strong>check-boot-mode.sh</strong> - 启动模式检测</summary>

**功能说明**：
- ✅ UEFI/BIOS 启动模式自动检测
- ✅ 系统架构和硬件信息显示
- ✅ 可用磁盘列表和建议
- ✅ 安装前系统兼容性检查

**使用场景**：安装前的系统环境检查
</details>

<details>
<summary>📶 <strong>wifi-helper.sh</strong> - WiFi连接助手</summary>

**功能说明**：
- ✅ 扫描并显示可用 WiFi 网络
- ✅ 交互式网络连接管理
- ✅ 已保存网络的管理
- ✅ 网络连接状态检查

**支持的操作**：
```bash
./modules/wifi-helper.sh                    # 交互模式
./modules/wifi-helper.sh list               # 列出网络
./modules/wifi-helper.sh connect SSID pass  # 连接网络
./modules/wifi-helper.sh status             # 查看状态
```
</details>

<details>
<summary>🌐 <strong>check-hyprland-network.sh</strong> - Hyprland网络检查</summary>

**功能说明**：
- ✅ NetworkManager 服务状态检查
- ✅ 网络 applet 安装状态验证
- ✅ 蓝牙硬件和服务检查
- ✅ Waybar 网络模块配置检查

**检查项目**：
- NetworkManager 和 nm-applet
- 蓝牙支持 (bluez + blueman)
- WiFi 硬件检测
- 网络连接测试
</details>

<details>
<summary>⚙️ <strong>setup-hyprland-network.sh</strong> - Hyprland网络配置</summary>

**功能说明**：
- ✅ 安装完整的网络管理组件
- ✅ 配置 Hyprland 自启动项
- ✅ 设置 Waybar 网络和蓝牙模块
- ✅ 创建网络故障排除脚本

**自动配置**：
- NetworkManager + nm-applet
- 蓝牙支持完整配置
- Waybar 状态栏集成
- 网络管理别名和快捷命令
</details>

<details>
<summary>🔧 <strong>post-install-config.sh</strong> - 安装后配置</summary>

**功能说明**：
- ✅ Pacman 配置优化（并行下载、彩色输出）
- ✅ AUR 助手 (yay) 自动安装
- ✅ 镜像源配置和优化
- ✅ 开发环境和字体配置

**优化项目**：
- 系统性能调优
- 安全配置和防火墙
- Shell 环境配置
- Git 和开发工具设置
</details>

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

### 2. 下载安装脚本

#### 方法一：完整下载（推荐）
```bash
# 下载完整项目
curl -L https://github.com/Tehsky/archlinux-install-btrfs/archive/main.zip -o archlinux-install.zip
unzip archlinux-install.zip
cd archlinux-install-btrfs-main
```

#### 方法二：Git克隆
```bash
# 克隆仓库
git clone https://github.com/Tehsky/archlinux-install-btrfs.git
cd archlinux-install-btrfs
```

#### 方法三：单独下载主脚本
```bash
# 下载主安装脚本
curl -O https://raw.githubusercontent.com/Tehsky/archlinux-install-btrfs/main/install-archlinux-btrfs.sh
chmod +x install-archlinux-btrfs.sh
```

### 3. 检查系统环境（可选但推荐）

```bash
# 运行启动模式检测
chmod +x modules/check-boot-mode.sh
./modules/check-boot-mode.sh
```

### 4. 运行安装脚本

⚠️ **重要**: 此脚本必须以 **root 权限** 运行

```bash
# 方法一：使用 sudo（推荐）
sudo ./install-archlinux-btrfs.sh

# 方法二：切换到 root 用户
su -
./install-archlinux-btrfs.sh

# 方法三：在 Arch Linux Live 环境中直接运行（已经是root）
./install-archlinux-btrfs.sh
```

> **说明**: 脚本需要root权限来进行磁盘分区、系统安装、用户创建等操作

### 5. 配置安装选项

安装脚本采用 **前置配置 + 无人值守安装** 的模式：

#### 📋 **配置阶段**（交互式）
1. **🌐 自动换源** - 优先使用国内镜像源加速下载
2. **🔍 系统检查** - 自动检测启动模式和硬件信息
3. **💾 磁盘选择** - 从列表中选择安装目标磁盘（⚠️ 会完全清空）
4. **👤 用户设置** - 设置用户名、密码（带确认）、主机名
5. **🖥️ 桌面环境** - 从6个选项中选择您喜欢的桌面环境
6. **✅ 最终确认** - 输入"YES"确认开始安装

#### 🚀 **安装阶段**（无人值守）
配置完成后，安装过程完全自动化，包含5个主要步骤：
- **Step 1/5**: 安装基础系统（10-20分钟）
- **Step 2/5**: 配置文件系统和分区
- **Step 3/5**: 配置系统设置、用户和引导程序
- **Step 4/5**: 安装选定的桌面环境
- **Step 5/5**: 完成安装和清理

#### 🎯 **安装特性**
- ✅ **前置换源** - 安装开始前配置最快的镜像源
- ✅ **智能验证** - 用户名、密码、主机名格式验证
- ✅ **磁盘选择菜单** - 自动列出可用磁盘，数字选择
- ✅ **密码确认** - 用户密码和root密码都需要二次确认
- ✅ **安全确认** - 最终确认需要输入"YES"防止误操作
- ✅ **无人值守** - 配置完成后自动安装，无需人工干预
- ✅ **进度显示** - 清晰的安装进度和预计时间

### 6. 等待安装完成

#### ⏱️ **预计安装时间**
| 网络环境 | 桌面环境 | 预计时间 |
|----------|----------|----------|
| **国内网络** | Minimal | 15-25分钟 |
| **国内网络** | Hyprland/i3 | 20-35分钟 |
| **国内网络** | KDE/GNOME/XFCE | 30-50分钟 |
| **国际网络** | 任意环境 | +10-20分钟 |

#### 📊 **安装进度说明**
- **Step 1/5** 通常是最耗时的步骤（下载基础系统）
- 脚本会显示详细的进度信息
- 请保持网络连接稳定，不要中断安装过程

### 7. 安装后配置（重启后执行）

```bash
# 系统优化和配置
./modules/post-install-config.sh

# 如果选择了Hyprland，额外配置网络
./modules/setup-hyprland-network.sh
./modules/check-hyprland-network.sh
```

## 🖥️ 桌面环境选择

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

## 🚀 安装后配置

### 重启进入新系统

安装完成后，系统会提示重启。移除安装介质后重启进入新安装的系统。

### 运行后配置脚本

```bash
# 如果之前下载了完整项目
cd archlinux-install-btrfs-main
./modules/post-install-config.sh

# 或者单独下载后配置脚本
curl -O https://raw.githubusercontent.com/Tehsky/archlinux-install-btrfs/main/modules/post-install-config.sh
chmod +x post-install-config.sh
./post-install-config.sh
```

### Hyprland 用户额外配置

如果您选择了 Hyprland 桌面环境：

```bash
# 配置网络支持
./modules/setup-hyprland-network.sh

# 检查网络配置
./modules/check-hyprland-network.sh

# 启动 Hyprland
Hyprland
```

**Hyprland 快捷键**：
- `Super + Q` - 打开终端
- `Super + R` - 应用启动器
- `Super + E` - 文件管理器
- `Super + C` - 关闭窗口

## 💾 技术特性

### 🗂️ Btrfs 文件系统优势

| 特性 | 说明 | 优势 |
|------|------|------|
| **子卷** | 独立的文件系统分区 | 灵活的空间管理 |
| **快照** | 系统状态备份 | 快速回滚和恢复 |
| **压缩** | 透明数据压缩 | 节省存储空间 |
| **校验和** | 数据完整性检查 | 防止数据损坏 |

### 📸 快照管理

```bash
# 查看快照
sudo snapper -c root list

# 创建手动快照
sudo snapper -c root create --description "安装后配置"

# 从快照恢复（GRUB菜单中选择）
# 重启 → Advanced options → Snapshot 选项
```

### 🔧 系统分区方案

#### UEFI 模式（推荐）
```
/dev/sdX1  512MB   FAT32   /boot/efi (EFI系统分区)
/dev/sdX2  剩余    Btrfs   /         (根分区，包含/boot目录和子卷)
```

#### BIOS/Legacy 模式
```
/dev/sdX1  全部    Btrfs   /         (根分区，包含子卷)
```

#### Btrfs 子卷结构
```
@           →  /           (根目录)
@home       →  /home       (用户目录)
@var        →  /var        (系统变量)
@tmp        →  /tmp        (临时文件)
@snapshots  →  /.snapshots (快照存储)
```

## 🛠️ 故障排除

### 常见问题

<details>
<summary><strong>❓ 安装过程中网络连接失败</strong></summary>

**解决方案**：
```bash
# 检查网络接口
ip link show

# 有线网络
sudo dhcpcd

# 无线网络
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "WiFi名称"
exit

# 或使用WiFi助手
./modules/wifi-helper.sh
```
</details>

<details>
<summary><strong>❓ GRUB安装失败</strong></summary>

**可能原因**：
- UEFI/BIOS模式检测错误
- EFI分区挂载问题
- 磁盘权限问题

**解决方案**：
```bash
# 检查启动模式
ls /sys/firmware/efi/efivars

# 重新挂载EFI分区（UEFI模式）
sudo mount /dev/sdX1 /boot/efi

# 重新安装GRUB
sudo grub-install --target=x86_64-efi --efi-directory=/boot/efi
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
</details>

<details>
<summary><strong>❓ Hyprland启动黑屏</strong></summary>

**解决方案**：
```bash
# 检查显卡驱动
lspci | grep VGA

# 安装显卡驱动
sudo pacman -S mesa xf86-video-amdgpu  # AMD
sudo pacman -S nvidia nvidia-utils     # NVIDIA

# 检查Hyprland配置
cat ~/.config/hypr/hyprland.conf

# 重新配置网络
./modules/setup-hyprland-network.sh
```
</details>

<details>
<summary><strong>❓ 系统无法启动</strong></summary>

**解决方案**：
1. **从快照恢复**：
   - 重启进入GRUB菜单
   - 选择 "Advanced options"
   - 选择可用的快照启动

2. **手动修复**：
   ```bash
   # 从Live USB启动
   # 挂载系统分区
   sudo mount -o subvol=@ /dev/sdX2 /mnt
   sudo arch-chroot /mnt

   # 修复GRUB
   grub-mkconfig -o /boot/grub/grub.cfg
   ```
</details>

## 📚 进阶使用

### 🔄 快照管理

```bash
# 查看所有快照
sudo snapper -c root list

# 创建手动快照
sudo snapper -c root create --description "更新前备份"

# 从GRUB菜单恢复快照
# 重启 → Advanced options → 选择快照
```

### 🌐 网络管理（Hyprland）

```bash
# WiFi连接
nmcli device wifi list
nmcli device wifi connect "SSID" password "password"

# 网络状态
nmcli device status

# 使用WiFi助手
./modules/wifi-helper.sh
```

### 🎨 自定义配置

```bash
# Hyprland配置文件
~/.config/hypr/hyprland.conf

# Waybar配置
~/.config/waybar/config
~/.config/waybar/style.css

# 应用启动器配置
~/.config/wofi/config
```

## 🤝 贡献指南

欢迎贡献代码和建议！

### 如何贡献
1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 报告问题
- 使用 [GitHub Issues](https://github.com/Tehsky/archlinux-install-btrfs/issues)
- 提供详细的错误信息和系统环境
- 包含相关的日志文件

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🙏 致谢

- [Arch Linux](https://archlinux.org/) 社区
- [Hyprland](https://hyprland.org/) 开发团队
- [Btrfs](https://btrfs.wiki.kernel.org/) 开发者
- 所有贡献者和用户

## ⭐ Star History

如果这个项目对您有帮助，请给个 Star ⭐

---

<div align="center">

**🐧 让 Arch Linux 安装更简单！**

[⬆️ 回到顶部](#-arch-linux-自动安装脚本)

</div>

