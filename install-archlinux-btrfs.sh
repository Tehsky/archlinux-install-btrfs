#!/bin/bash

# Arch Linux Installation Script with Btrfs and Multiple Desktop Environments
# Features:
# - Btrfs filesystem with snapshots
# - Multiple desktop environment choices (Hyprland/KDE/GNOME/XFCE/i3/Minimal)
# - Auto-detect UEFI/BIOS boot mode
# - User disk selection with automatic partitioning
# - USTC mirrors and archlinuxcn repository
# - Minimal/optimized package installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root. Please run as a regular user."
fi

# Get script directory for module access
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if modules directory exists
if [[ ! -d "$SCRIPT_DIR/modules" ]]; then
    error "Modules directory not found. Please ensure all files are in the correct location."
fi

# Run boot mode check module
log "Running boot mode detection..."
if [[ -f "$SCRIPT_DIR/modules/check-boot-mode.sh" ]]; then
    bash "$SCRIPT_DIR/modules/check-boot-mode.sh"
    echo
    read -p "Press Enter to continue with installation..."
fi

# Detect boot mode (UEFI or BIOS)
if [[ -d /sys/firmware/efi/efivars ]]; then
    BOOT_MODE="UEFI"
    log "Detected UEFI boot mode"
else
    BOOT_MODE="BIOS"
    log "Detected BIOS/Legacy boot mode"
fi

# Update system clock
log "Updating system clock..."
timedatectl set-ntp true

# Display available disks
log "Available disks:"
lsblk -d -o NAME,SIZE,MODEL | grep -E "sd|nvme|vd"

echo
read -p "Enter the disk to install Arch Linux (e.g., /dev/sda, /dev/nvme0n1): " DISK

if [[ ! -b "$DISK" ]]; then
    error "Invalid disk: $DISK"
fi

warn "This will COMPLETELY ERASE $DISK. All data will be lost!"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    error "Installation cancelled."
fi

# Get user information
echo
log "Setting up user information..."
read -p "Enter username: " USERNAME
read -s -p "Enter password for $USERNAME: " USER_PASSWORD
echo
read -s -p "Enter root password: " ROOT_PASSWORD
echo
read -p "Enter hostname: " HOSTNAME

# Desktop environment selection
echo
log "Available desktop environments:"
echo "1) Hyprland (Wayland compositor - minimal)"
echo "2) KDE Plasma (full-featured)"
echo "3) GNOME (modern desktop)"
echo "4) XFCE (lightweight)"
echo "5) i3 (tiling window manager)"
echo "6) Minimal (no desktop environment)"
echo
read -p "Choose desktop environment (1-6): " DE_CHOICE

case $DE_CHOICE in
    1) DESKTOP_ENV="hyprland" ;;
    2) DESKTOP_ENV="kde" ;;
    3) DESKTOP_ENV="gnome" ;;
    4) DESKTOP_ENV="xfce" ;;
    5) DESKTOP_ENV="i3" ;;
    6) DESKTOP_ENV="minimal" ;;
    *) error "Invalid choice. Please select 1-6." ;;
esac

log "Selected desktop environment: $DESKTOP_ENV"

# Partition the disk based on boot mode
log "Partitioning disk $DISK for $BOOT_MODE mode..."

if [[ "$BOOT_MODE" == "UEFI" ]]; then
    # UEFI partitioning scheme
    parted -s "$DISK" mklabel gpt
    parted -s "$DISK" mkpart primary fat32 1MiB 512MiB
    parted -s "$DISK" set 1 esp on
    parted -s "$DISK" mkpart primary btrfs 512MiB 100%

    # Determine partition names for UEFI
    if [[ "$DISK" == *"nvme"* ]]; then
        BOOT_PARTITION="${DISK}p1"
        ROOT_PARTITION="${DISK}p2"
    else
        BOOT_PARTITION="${DISK}1"
        ROOT_PARTITION="${DISK}2"
    fi

    log "EFI partition: $BOOT_PARTITION"
    log "Root partition: $ROOT_PARTITION"

    # Format partitions for UEFI
    log "Formatting partitions for UEFI..."
    mkfs.fat -F32 "$BOOT_PARTITION"
    mkfs.btrfs -f "$ROOT_PARTITION"

else
    # BIOS partitioning scheme
    parted -s "$DISK" mklabel msdos
    parted -s "$DISK" mkpart primary btrfs 1MiB 100%
    parted -s "$DISK" set 1 boot on

    # Determine partition names for BIOS
    if [[ "$DISK" == *"nvme"* ]]; then
        ROOT_PARTITION="${DISK}p1"
    else
        ROOT_PARTITION="${DISK}1"
    fi

    log "Root partition: $ROOT_PARTITION"

    # Format partitions for BIOS
    log "Formatting partitions for BIOS..."
    mkfs.btrfs -f "$ROOT_PARTITION"
fi

# Mount root partition and create btrfs subvolumes
log "Creating btrfs subvolumes..."
mount "$ROOT_PARTITION" /mnt

# Create subvolumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@snapshots

umount /mnt

# Mount subvolumes
log "Mounting btrfs subvolumes..."
mount -o noatime,compress=zstd,space_cache=v2,subvol=@ "$ROOT_PARTITION" /mnt

if [[ "$BOOT_MODE" == "UEFI" ]]; then
    mkdir -p /mnt/{boot,home,var,tmp,.snapshots}
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@home "$ROOT_PARTITION" /mnt/home
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@var "$ROOT_PARTITION" /mnt/var
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@tmp "$ROOT_PARTITION" /mnt/tmp
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots "$ROOT_PARTITION" /mnt/.snapshots

    # Mount EFI partition
    mount "$BOOT_PARTITION" /mnt/boot
else
    mkdir -p /mnt/{home,var,tmp,.snapshots}
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@home "$ROOT_PARTITION" /mnt/home
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@var "$ROOT_PARTITION" /mnt/var
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@tmp "$ROOT_PARTITION" /mnt/tmp
    mount -o noatime,compress=zstd,space_cache=v2,subvol=@snapshots "$ROOT_PARTITION" /mnt/.snapshots

    # No separate boot partition for BIOS mode
fi

# Configure USTC mirrors
log "Configuring USTC mirrors..."
cat > /etc/pacman.d/mirrorlist << 'EOF'
# USTC Mirror
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch
# Tsinghua Mirror (backup)
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch
# Official mirrors (backup)
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
EOF

# Install base system
log "Installing base system..."
pacstrap /mnt base base-devel linux linux-firmware btrfs-progs

# Generate fstab
log "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Create chroot script
log "Creating chroot configuration script..."
cat > /mnt/chroot-config.sh << EOF
#!/bin/bash

# Boot mode and disk information
BOOT_MODE="$BOOT_MODE"
DISK="$DISK"
DESKTOP_ENV="$DESKTOP_ENV"

# Set timezone
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc

# Configure locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << 'HOSTS_EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS_EOF

# Configure USTC mirrors in chroot
cat > /etc/pacman.d/mirrorlist << 'MIRROR_EOF'
# USTC Mirror
Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch
# Tsinghua Mirror (backup)
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch
# Official mirrors (backup)
Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch
MIRROR_EOF

# Add archlinuxcn repository
cat >> /etc/pacman.conf << 'PACMAN_EOF'

[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch
PACMAN_EOF

# Update package database and install archlinuxcn-keyring
pacman -Sy --noconfirm
pacman -S --noconfirm archlinuxcn-keyring

# Install essential packages
pacman -S --noconfirm grub efibootmgr networkmanager \
    wireless_tools wpa_supplicant dialog os-prober mtools dosfstools \
    reflector git curl wget vim nano sudo zsh \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber

# Install desktop environment specific packages
case "$DESKTOP_ENV" in
    "hyprland")
        log "Installing Hyprland (minimal Wayland compositor)..."
        pacman -S --noconfirm hyprland waybar wofi kitty thunar firefox \
            xdg-desktop-portal-hyprland polkit-gnome grim slurp wl-clipboard \
            brightnessctl playerctl pamixer ttf-font-awesome \
            network-manager-applet blueman
        ;;
    "kde")
        log "Installing KDE Plasma (minimal)..."
        pacman -S --noconfirm plasma-desktop plasma-nm plasma-pa \
            konsole dolphin kate firefox sddm \
            xdg-desktop-portal-kde breeze-gtk kde-gtk-config
        systemctl enable sddm
        ;;
    "gnome")
        log "Installing GNOME (minimal)..."
        pacman -S --noconfirm gnome-shell gnome-terminal nautilus \
            gnome-control-center gnome-session gdm firefox \
            xdg-desktop-portal-gnome gnome-keyring
        systemctl enable gdm
        ;;
    "xfce")
        log "Installing XFCE (lightweight)..."
        pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
            firefox thunar-archive-plugin xarchiver
        systemctl enable lightdm
        ;;
    "i3")
        log "Installing i3 (tiling window manager)..."
        pacman -S --noconfirm i3-wm i3status i3lock dmenu \
            xorg-server xorg-xinit lightdm lightdm-gtk-greeter \
            alacritty firefox feh picom
        systemctl enable lightdm
        ;;
    "minimal")
        log "Installing minimal system (no desktop environment)..."
        # Only essential packages already installed
        ;;
esac

# Install snapshot tools
pacman -S --noconfirm snapper snap-pac grub-btrfs

# Configure GRUB based on boot mode
if [[ "$BOOT_MODE" == "UEFI" ]]; then
    log "Installing GRUB for UEFI..."
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
else
    log "Installing GRUB for BIOS..."
    grub-install --target=i386-pc "$DISK" --recheck
fi

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

# Enable services
systemctl enable NetworkManager
systemctl enable reflector.timer

# Set root password
echo "root:$ROOT_PASSWORD" | chpasswd

# Create user
useradd -m -G wheel,audio,video,optical,storage -s /bin/bash $USERNAME
echo "$USERNAME:$USER_PASSWORD" | chpasswd

# Configure sudo
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Configure snapper for root subvolume
umount /.snapshots
rm -r /.snapshots
snapper -c root create-config /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -a
chmod 750 /.snapshots

# Configure snapper settings
sed -i 's/^TIMELINE_CREATE=.*/TIMELINE_CREATE="yes"/' /etc/snapper/configs/root
sed -i 's/^TIMELINE_CLEANUP=.*/TIMELINE_CLEANUP="yes"/' /etc/snapper/configs/root
sed -i 's/^NUMBER_CLEANUP=.*/NUMBER_CLEANUP="yes"/' /etc/snapper/configs/root
sed -i 's/^NUMBER_MIN_AGE=.*/NUMBER_MIN_AGE="1800"/' /etc/snapper/configs/root
sed -i 's/^NUMBER_LIMIT=.*/NUMBER_LIMIT="10"/' /etc/snapper/configs/root
sed -i 's/^NUMBER_LIMIT_IMPORTANT=.*/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root

# Enable snapper services
systemctl enable snapper-timeline.timer
systemctl enable snapper-cleanup.timer
systemctl enable grub-btrfsd

# Create desktop environment specific configurations
case "$DESKTOP_ENV" in
    "hyprland")
        log "Creating Hyprland configuration..."
        mkdir -p /home/$USERNAME/.config/hypr
        cat > /home/$USERNAME/.config/hypr/hyprland.conf << 'HYPR_EOF'
# Hyprland Configuration

# Monitor configuration
monitor=,preferred,auto,auto

# Input configuration
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    touchpad {
        natural_scroll = no
    }

    sensitivity = 0
}

# General configuration
general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle
}

# Decoration
decoration {
    rounding = 10

    blur {
        enabled = true
        size = 3
        passes = 1
    }

    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = yes

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layout
dwindle {
    pseudotile = yes
    preserve_split = yes
}

# Window rules
windowrule = float, ^(kitty)$
windowrule = float, ^(thunar)$

# Key bindings
\$mainMod = SUPER

bind = \$mainMod, Q, exec, kitty
bind = \$mainMod, C, killactive,
bind = \$mainMod, M, exit,
bind = \$mainMod, E, exec, thunar
bind = \$mainMod, V, togglefloating,
bind = \$mainMod, R, exec, wofi --show drun
bind = \$mainMod, P, pseudo,
bind = \$mainMod, J, togglesplit,

# Move focus
bind = \$mainMod, left, movefocus, l
bind = \$mainMod, right, movefocus, r
bind = \$mainMod, up, movefocus, u
bind = \$mainMod, down, movefocus, d

# Switch workspaces
bind = \$mainMod, 1, workspace, 1
bind = \$mainMod, 2, workspace, 2
bind = \$mainMod, 3, workspace, 3
bind = \$mainMod, 4, workspace, 4
bind = \$mainMod, 5, workspace, 5
bind = \$mainMod, 6, workspace, 6
bind = \$mainMod, 7, workspace, 7
bind = \$mainMod, 8, workspace, 8
bind = \$mainMod, 9, workspace, 9
bind = \$mainMod, 0, workspace, 10

# Move active window to workspace
bind = \$mainMod SHIFT, 1, movetoworkspace, 1
bind = \$mainMod SHIFT, 2, movetoworkspace, 2
bind = \$mainMod SHIFT, 3, movetoworkspace, 3
bind = \$mainMod SHIFT, 4, movetoworkspace, 4
bind = \$mainMod SHIFT, 5, movetoworkspace, 5
bind = \$mainMod SHIFT, 6, movetoworkspace, 6
bind = \$mainMod SHIFT, 7, movetoworkspace, 7
bind = \$mainMod SHIFT, 8, movetoworkspace, 8
bind = \$mainMod SHIFT, 9, movetoworkspace, 9
bind = \$mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through workspaces
bind = \$mainMod, mouse_down, workspace, e+1
bind = \$mainMod, mouse_up, workspace, e-1

# Move/resize windows
bindm = \$mainMod, mouse:272, movewindow
bindm = \$mainMod, mouse:273, resizewindow

# Volume and brightness controls
bind = , XF86AudioRaiseVolume, exec, pamixer -i 5
bind = , XF86AudioLowerVolume, exec, pamixer -d 5
bind = , XF86AudioMute, exec, pamixer -t
bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%
bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

# Screenshot
bind = \$mainMod, Print, exec, grim -g "\$(slurp)" - | wl-copy

# Autostart
exec-once = waybar
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = nm-applet --indicator
exec-once = blueman-applet
HYPR_EOF
        ;;
    "kde")
        log "Creating KDE configuration..."
        # KDE will create its own config on first login
        # Set some basic preferences
        mkdir -p /home/$USERNAME/.config
        cat > /home/$USERNAME/.config/kdeglobals << 'KDE_EOF'
[General]
BrowserApplication=firefox.desktop

[KDE]
SingleClick=false
KDE_EOF
        ;;
    "gnome")
        log "Creating GNOME configuration..."
        # GNOME will create its own config on first login
        # Set some basic preferences via dconf
        mkdir -p /home/$USERNAME/.config/dconf
        ;;
    "xfce")
        log "Creating XFCE configuration..."
        mkdir -p /home/$USERNAME/.config/xfce4/xfconf/xfce-perchannel-xml
        cat > /home/$USERNAME/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'XFCE_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
XFCE_EOF
        ;;
    "i3")
        log "Creating i3 configuration..."
        mkdir -p /home/$USERNAME/.config/i3
        cat > /home/$USERNAME/.config/i3/config << 'I3_EOF'
# i3 config file (v4)
set \$mod Mod4

# Font
font pango:monospace 8

# Use Mouse+\$mod to drag floating windows
floating_modifier \$mod

# Start a terminal
bindsym \$mod+Return exec alacritty

# Kill focused window
bindsym \$mod+Shift+q kill

# Start dmenu
bindsym \$mod+d exec dmenu_run

# Change focus
bindsym \$mod+j focus left
bindsym \$mod+k focus down
bindsym \$mod+l focus up
bindsym \$mod+semicolon focus right

# Move focused window
bindsym \$mod+Shift+j move left
bindsym \$mod+Shift+k move down
bindsym \$mod+Shift+l move up
bindsym \$mod+Shift+semicolon move right

# Split orientation
bindsym \$mod+h split h
bindsym \$mod+v split v

# Fullscreen
bindsym \$mod+f fullscreen toggle

# Toggle floating
bindsym \$mod+Shift+space floating toggle

# Workspaces
bindsym \$mod+1 workspace 1
bindsym \$mod+2 workspace 2
bindsym \$mod+3 workspace 3
bindsym \$mod+4 workspace 4
bindsym \$mod+5 workspace 5

# Move to workspace
bindsym \$mod+Shift+1 move container to workspace 1
bindsym \$mod+Shift+2 move container to workspace 2
bindsym \$mod+Shift+3 move container to workspace 3
bindsym \$mod+Shift+4 move container to workspace 4
bindsym \$mod+Shift+5 move container to workspace 5

# Restart i3
bindsym \$mod+Shift+r restart

# Exit i3
bindsym \$mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

# Status bar
bar {
    status_command i3status
}
I3_EOF
        ;;
    "minimal")
        log "Minimal installation - no desktop configuration needed"
        ;;
esac

# Set ownership for user config files
if [[ "$DESKTOP_ENV" != "minimal" ]]; then
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.config 2>/dev/null || true
fi

EOF

chmod +x /mnt/chroot-config.sh

# Execute chroot script
log "Configuring system in chroot..."
arch-chroot /mnt ./chroot-config.sh

# Clean up
rm /mnt/chroot-config.sh

log "Installation completed successfully!"
log "Boot mode: $BOOT_MODE"
log "Please reboot and remove the installation media."
log ""
log "Post-installation notes:"
log "1. After reboot, log in as $USERNAME"

case "$DESKTOP_ENV" in
    "hyprland")
        log "2. Start Hyprland with: Hyprland"
        log "3. Use Super+Q for terminal, Super+R for app launcher"
        log "4. Network applet will auto-start (nm-applet)"
        log "5. Check network: ./modules/check-hyprland-network.sh"
        log "6. Setup network: ./modules/setup-hyprland-network.sh"
        log "7. Post-install config: ./modules/post-install-config.sh"
        ;;
    "kde")
        log "2. KDE Plasma will start automatically via SDDM"
        log "3. Customize desktop via System Settings"
        ;;
    "gnome")
        log "2. GNOME will start automatically via GDM"
        log "3. Access settings via Activities > Settings"
        ;;
    "xfce")
        log "2. XFCE will start automatically via LightDM"
        log "3. Right-click desktop for menu and settings"
        ;;
    "i3")
        log "2. i3 will start automatically via LightDM"
        log "3. Use Super+Return for terminal, Super+D for dmenu"
        ;;
    "minimal")
        log "2. Minimal system - install desktop environment as needed"
        log "3. Use 'sudo pacman -S' to install additional packages"
        ;;
esac

log ""
log "Snapshot management:"
log "- Snapshots are automatically created and managed by snapper"
log "- Create manual snapshots: sudo snapper -c root create --description 'description'"
log "- List snapshots: sudo snapper -c root list"
log "- Boot from snapshots via GRUB menu (Advanced options)"
log ""
warn "Don't forget to:"
warn "1. Configure your network connection"
warn "2. Install additional software as needed"
warn "3. Configure your desktop environment preferences"

echo
log "Available post-installation modules:"
log "1. modules/post-install-config.sh - System optimization and configuration"
log "2. modules/setup-hyprland-network.sh - Hyprland network setup (if using Hyprland)"
log "3. modules/check-hyprland-network.sh - Network connectivity check"
log "4. modules/wifi-helper.sh - WiFi connection assistant"

echo
log "Installation completed! You can now reboot and run the post-installation modules."

read -p "Press Enter to continue..."
EOF
