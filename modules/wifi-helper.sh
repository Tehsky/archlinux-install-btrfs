#!/bin/bash

# WiFi Connection Helper for Hyprland
# Simple script to help connect to WiFi networks

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

echo -e "${BLUE}=== WiFi Connection Helper ===${NC}"
echo

# Check if NetworkManager is running
if ! systemctl is-active --quiet NetworkManager; then
    error "NetworkManager is not running!"
    echo "Please start it with: sudo systemctl start NetworkManager"
    exit 1
fi

# Function to list WiFi networks
list_networks() {
    echo -e "${BLUE}=== Available WiFi Networks ===${NC}"
    nmcli device wifi list 2>/dev/null || {
        error "Failed to scan WiFi networks"
        echo "Try: sudo nmcli device wifi rescan"
        return 1
    }
}

# Function to connect to WiFi
connect_wifi() {
    local ssid="$1"
    local password="$2"
    
    if [[ -z "$ssid" ]]; then
        error "SSID is required"
        return 1
    fi
    
    log "Connecting to '$ssid'..."
    
    if [[ -n "$password" ]]; then
        nmcli device wifi connect "$ssid" password "$password"
    else
        # Try to connect without password (open network)
        nmcli device wifi connect "$ssid"
    fi
    
    if [[ $? -eq 0 ]]; then
        log "Successfully connected to '$ssid'"
        show_status
    else
        error "Failed to connect to '$ssid'"
        echo "Please check the network name and password"
    fi
}

# Function to show current status
show_status() {
    echo -e "${BLUE}=== Current Network Status ===${NC}"
    nmcli device status
    echo
    echo -e "${BLUE}=== Active Connections ===${NC}"
    nmcli connection show --active
}

# Function to disconnect from current network
disconnect_wifi() {
    local connection=$(nmcli -t -f NAME connection show --active | head -1)
    
    if [[ -n "$connection" ]]; then
        log "Disconnecting from '$connection'..."
        nmcli connection down "$connection"
        log "Disconnected"
    else
        warn "No active WiFi connection found"
    fi
}

# Function to forget a network
forget_network() {
    local ssid="$1"
    
    if [[ -z "$ssid" ]]; then
        error "SSID is required"
        return 1
    fi
    
    log "Forgetting network '$ssid'..."
    nmcli connection delete "$ssid" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        log "Successfully forgot network '$ssid'"
    else
        warn "Network '$ssid' was not saved or already forgotten"
    fi
}

# Function to show saved networks
show_saved() {
    echo -e "${BLUE}=== Saved WiFi Networks ===${NC}"
    nmcli connection show | grep wifi
}

# Interactive mode
interactive_mode() {
    while true; do
        echo
        echo -e "${BLUE}=== WiFi Helper Menu ===${NC}"
        echo "1) List available networks"
        echo "2) Connect to network"
        echo "3) Show current status"
        echo "4) Disconnect current network"
        echo "5) Show saved networks"
        echo "6) Forget a network"
        echo "7) Rescan networks"
        echo "8) Exit"
        echo
        read -p "Choose an option (1-8): " choice
        
        case $choice in
            1)
                list_networks
                ;;
            2)
                read -p "Enter network name (SSID): " ssid
                read -s -p "Enter password (leave empty for open network): " password
                echo
                connect_wifi "$ssid" "$password"
                ;;
            3)
                show_status
                ;;
            4)
                disconnect_wifi
                ;;
            5)
                show_saved
                ;;
            6)
                read -p "Enter network name to forget: " ssid
                forget_network "$ssid"
                ;;
            7)
                log "Rescanning networks..."
                nmcli device wifi rescan
                sleep 2
                list_networks
                ;;
            8)
                log "Goodbye!"
                exit 0
                ;;
            *)
                warn "Invalid option. Please choose 1-8."
                ;;
        esac
    done
}

# Command line mode
if [[ $# -eq 0 ]]; then
    # No arguments, start interactive mode
    interactive_mode
else
    case "$1" in
        "list"|"ls")
            list_networks
            ;;
        "connect"|"conn")
            if [[ -n "$2" ]]; then
                connect_wifi "$2" "$3"
            else
                error "Usage: $0 connect <SSID> [password]"
            fi
            ;;
        "status"|"st")
            show_status
            ;;
        "disconnect"|"disc")
            disconnect_wifi
            ;;
        "forget")
            if [[ -n "$2" ]]; then
                forget_network "$2"
            else
                error "Usage: $0 forget <SSID>"
            fi
            ;;
        "saved")
            show_saved
            ;;
        "rescan")
            log "Rescanning networks..."
            nmcli device wifi rescan
            sleep 2
            list_networks
            ;;
        "help"|"-h"|"--help")
            echo "WiFi Connection Helper"
            echo
            echo "Usage:"
            echo "  $0                    # Interactive mode"
            echo "  $0 list               # List available networks"
            echo "  $0 connect <SSID> [password]  # Connect to network"
            echo "  $0 status             # Show current status"
            echo "  $0 disconnect         # Disconnect current network"
            echo "  $0 saved              # Show saved networks"
            echo "  $0 forget <SSID>      # Forget a network"
            echo "  $0 rescan             # Rescan for networks"
            echo "  $0 help               # Show this help"
            ;;
        *)
            error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
fi
