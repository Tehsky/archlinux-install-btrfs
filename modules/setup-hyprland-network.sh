#!/bin/bash

# Hyprland Network Setup Script
# This script configures network and WiFi support for Hyprland

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if running as regular user
if [[ $EUID -eq 0 ]]; then
    error "This script should be run as a regular user, not root."
fi

echo -e "${BLUE}=== Hyprland Network Setup ===${NC}"
echo

# Check if Hyprland is installed
if ! command -v Hyprland &> /dev/null; then
    error "Hyprland is not installed. Please install Hyprland first."
fi

log "Setting up network support for Hyprland..."

# Install network packages if not already installed
log "Installing network packages..."
sudo pacman -S --needed --noconfirm \
    networkmanager \
    network-manager-applet \
    wireless_tools \
    wpa_supplicant \
    bluez \
    bluez-utils \
    blueman

# Enable NetworkManager service
log "Enabling NetworkManager service..."
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Enable Bluetooth service
log "Enabling Bluetooth service..."
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Update Hyprland configuration
log "Updating Hyprland configuration..."
HYPR_CONFIG="$HOME/.config/hypr/hyprland.conf"

if [[ -f "$HYPR_CONFIG" ]]; then
    # Backup existing config
    cp "$HYPR_CONFIG" "$HYPR_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Remove old autostart entries if they exist
    sed -i '/exec-once = nm-applet/d' "$HYPR_CONFIG"
    sed -i '/exec-once = blueman-applet/d' "$HYPR_CONFIG"
    
    # Add network autostart entries
    if ! grep -q "# Network and Bluetooth" "$HYPR_CONFIG"; then
        cat >> "$HYPR_CONFIG" << 'EOF'

# Network and Bluetooth
exec-once = nm-applet --indicator
exec-once = blueman-applet
EOF
        log "Added network autostart to Hyprland config"
    else
        log "Network autostart already configured in Hyprland"
    fi
else
    warn "Hyprland config not found. Creating basic config..."
    mkdir -p "$HOME/.config/hypr"
    cat > "$HYPR_CONFIG" << 'EOF'
# Basic Hyprland configuration with network support

# Monitor configuration
monitor=,preferred,auto,auto

# Input configuration
input {
    kb_layout = us
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

# Key bindings
$mainMod = SUPER
bind = $mainMod, Q, exec, kitty
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, wofi --show drun

# Network and Bluetooth
exec-once = nm-applet --indicator
exec-once = blueman-applet
EOF
fi

# Create network management aliases
log "Creating network management aliases..."
mkdir -p "$HOME/.local/bin"

cat >> "$HOME/.bashrc" << 'EOF'

# Network management aliases
alias wifi-list='nmcli device wifi list'
alias wifi-connect='nmcli device wifi connect'
alias wifi-status='nmcli device status'
alias wifi-show='nmcli connection show'
EOF

if [[ -f "$HOME/.zshrc" ]]; then
cat >> "$HOME/.zshrc" << 'EOF'

# Network management aliases
alias wifi-list='nmcli device wifi list'
alias wifi-connect='nmcli device wifi connect'
alias wifi-status='nmcli device status'
alias wifi-show='nmcli connection show'
EOF
fi

# Create network troubleshooting script
log "Creating network troubleshooting script..."
cat > "$HOME/.local/bin/hypr-network-fix" << 'EOF'
#!/bin/bash

echo "=== Hyprland Network Troubleshooting ==="
echo

echo "1. Restarting NetworkManager..."
sudo systemctl restart NetworkManager

echo "2. Restarting network applets..."
pkill nm-applet
pkill blueman-applet
sleep 2
nm-applet --indicator &
blueman-applet &

echo "3. Checking network status..."
nmcli device status

echo "4. Scanning for WiFi networks..."
nmcli device wifi rescan
sleep 3
nmcli device wifi list

echo
echo "Network troubleshooting completed!"
echo "If issues persist, check: journalctl -u NetworkManager"
EOF

chmod +x "$HOME/.local/bin/hypr-network-fix"

log "Network setup completed successfully!"
echo
echo -e "${BLUE}=== Usage Instructions ===${NC}"
echo
echo "Network management:"
echo "• GUI: Click network icon in system tray"
echo "• CLI: nmcli device wifi list"
echo "• Connect: nmcli device wifi connect 'SSID' password 'password'"
echo
echo "Bluetooth management:"
echo "• GUI: Click Bluetooth icon in system tray"
echo "• CLI: bluetoothctl"
echo
echo "Troubleshooting:"
echo "• Run: hypr-network-fix"
echo "• Check logs: journalctl -u NetworkManager"
echo
echo "Restart Hyprland to apply all changes!"
echo "Or run: nm-applet --indicator & blueman-applet &"
