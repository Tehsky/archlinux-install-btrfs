#!/bin/bash

# Hyprland Network and WiFi Support Check Script
# This script checks if Hyprland has proper network and WiFi support

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
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo -e "${BLUE}=== Hyprland Network & WiFi Support Check ===${NC}"
echo

# Check if running Hyprland
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]] || [[ "$HYPRLAND_INSTANCE_SIGNATURE" ]]; then
    log "Running in Hyprland environment"
else
    warn "Not currently running Hyprland"
    echo "This script can still check if network tools are installed."
fi

echo
echo -e "${BLUE}=== Network Manager Status ===${NC}"

# Check NetworkManager service
if systemctl is-active --quiet NetworkManager; then
    log "NetworkManager service is running"
else
    error "NetworkManager service is not running"
    echo "  Fix: sudo systemctl enable --now NetworkManager"
fi

# Check NetworkManager installation
if command -v nmcli &> /dev/null; then
    log "NetworkManager CLI (nmcli) is installed"
    
    # Show network status
    echo
    info "Current network connections:"
    nmcli connection show --active 2>/dev/null || echo "  No active connections"
    
    echo
    info "Available WiFi networks:"
    nmcli device wifi list 2>/dev/null | head -5 || echo "  WiFi not available or no networks found"
    
else
    error "NetworkManager is not installed"
    echo "  Fix: sudo pacman -S networkmanager"
fi

echo
echo -e "${BLUE}=== Network Applet (GUI) ===${NC}"

# Check nm-applet
if command -v nm-applet &> /dev/null; then
    log "NetworkManager Applet (nm-applet) is installed"
    
    # Check if nm-applet is running
    if pgrep -x nm-applet > /dev/null; then
        log "nm-applet is currently running"
    else
        warn "nm-applet is not running"
        echo "  Fix: nm-applet --indicator &"
    fi
else
    error "NetworkManager Applet is not installed"
    echo "  Fix: sudo pacman -S network-manager-applet"
fi

echo
echo -e "${BLUE}=== Bluetooth Support ===${NC}"

# Check Bluetooth service
if systemctl is-active --quiet bluetooth; then
    log "Bluetooth service is running"
else
    warn "Bluetooth service is not running"
    echo "  Fix: sudo systemctl enable --now bluetooth"
fi

# Check blueman
if command -v blueman-applet &> /dev/null; then
    log "Blueman applet is installed"
    
    # Check if blueman-applet is running
    if pgrep -x blueman-applet > /dev/null; then
        log "blueman-applet is currently running"
    else
        warn "blueman-applet is not running"
        echo "  Fix: blueman-applet &"
    fi
else
    warn "Blueman applet is not installed"
    echo "  Install: sudo pacman -S blueman"
fi

echo
echo -e "${BLUE}=== Waybar Network Module ===${NC}"

# Check Waybar configuration
WAYBAR_CONFIG="$HOME/.config/waybar/config"
if [[ -f "$WAYBAR_CONFIG" ]]; then
    if grep -q '"network"' "$WAYBAR_CONFIG"; then
        log "Waybar network module is configured"
    else
        warn "Waybar network module is not configured"
        echo "  Add 'network' to modules-right in $WAYBAR_CONFIG"
    fi
else
    warn "Waybar configuration not found"
    echo "  Expected location: $WAYBAR_CONFIG"
fi

echo
echo -e "${BLUE}=== Hardware Detection ===${NC}"

# Check WiFi hardware
if [[ -d /sys/class/net/wl* ]] || ip link show | grep -q "wl"; then
    log "WiFi hardware detected"
    
    # List WiFi interfaces
    echo "  WiFi interfaces:"
    ip link show | grep -E "wl|wlan" | awk '{print "    " $2}' | sed 's/://'
else
    warn "No WiFi hardware detected"
    echo "  This system may not have WiFi capability"
fi

# Check Ethernet hardware
if [[ -d /sys/class/net/en* ]] || ip link show | grep -q "en"; then
    log "Ethernet hardware detected"
    
    # List Ethernet interfaces
    echo "  Ethernet interfaces:"
    ip link show | grep -E "en|eth" | awk '{print "    " $2}' | sed 's/://'
else
    warn "No Ethernet hardware detected"
fi

echo
echo -e "${BLUE}=== Network Connectivity Test ===${NC}"

# Test internet connectivity
if ping -c 1 8.8.8.8 &> /dev/null; then
    log "Internet connectivity is working"
else
    error "No internet connectivity"
    echo "  Check your network connection"
fi

# Test DNS resolution
if nslookup google.com &> /dev/null; then
    log "DNS resolution is working"
else
    warn "DNS resolution issues"
    echo "  Check DNS settings: nmcli device show"
fi

echo
echo -e "${BLUE}=== Recommendations ===${NC}"

echo "For optimal Hyprland network experience:"
echo
echo "1. Essential packages:"
echo "   sudo pacman -S networkmanager network-manager-applet"
echo
echo "2. Enable services:"
echo "   sudo systemctl enable --now NetworkManager"
echo
echo "3. Add to Hyprland autostart:"
echo "   exec-once = nm-applet --indicator"
echo
echo "4. For Bluetooth:"
echo "   sudo pacman -S blueman"
echo "   sudo systemctl enable --now bluetooth"
echo "   exec-once = blueman-applet"
echo
echo "5. Waybar network module configuration:"
echo '   Add "network" to modules-right in ~/.config/waybar/config'
echo
echo "6. WiFi connection commands:"
echo "   nmcli device wifi list"
echo '   nmcli device wifi connect "SSID" password "password"'
echo
echo "7. Troubleshooting:"
echo "   nmcli device status"
echo "   nmcli connection show"
echo "   journalctl -u NetworkManager"

echo
if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    log "Hyprland network check completed!"
else
    info "Install Hyprland and run this script again for full testing"
fi
