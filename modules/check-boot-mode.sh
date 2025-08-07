#!/bin/bash

# Boot Mode Detection Script
# This script checks the current boot mode (UEFI or BIOS)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Boot Mode Detection ===${NC}"
echo

# Check for UEFI
if [[ -d /sys/firmware/efi/efivars ]]; then
    echo -e "${GREEN}✓ UEFI Boot Mode Detected${NC}"
    echo
    echo "Boot Mode: UEFI"
    echo "Partition Table: GPT (recommended)"
    echo "Boot Partition: EFI System Partition (ESP)"
    echo "GRUB Target: x86_64-efi"
    echo
    
    # Check EFI variables
    if [[ -r /sys/firmware/efi/efivars ]]; then
        echo -e "${GREEN}✓ EFI variables accessible${NC}"
    else
        echo -e "${YELLOW}⚠ EFI variables not accessible (may need root)${NC}"
    fi
    
    # Check for Secure Boot
    if [[ -f /sys/firmware/efi/efivars/SecureBoot-* ]]; then
        echo -e "${BLUE}ℹ Secure Boot information available${NC}"
    fi
    
else
    echo -e "${YELLOW}⚠ BIOS/Legacy Boot Mode Detected${NC}"
    echo
    echo "Boot Mode: BIOS/Legacy"
    echo "Partition Table: MBR or GPT"
    echo "Boot Partition: Not required (bootloader in MBR)"
    echo "GRUB Target: i386-pc"
    echo
    echo -e "${BLUE}ℹ Note: UEFI mode is recommended for modern systems${NC}"
fi

echo
echo -e "${BLUE}=== System Information ===${NC}"

# Check architecture
echo "Architecture: $(uname -m)"

# Check if running in live environment
if [[ -f /etc/arch-release ]] && [[ $(whoami) == "root" ]] && [[ -d /run/archiso ]]; then
    echo -e "${GREEN}✓ Running in Arch Linux Live Environment${NC}"
elif [[ -f /etc/arch-release ]]; then
    echo -e "${BLUE}ℹ Running on installed Arch Linux system${NC}"
else
    echo -e "${YELLOW}⚠ Not running on Arch Linux${NC}"
fi

# Check available disks
echo
echo -e "${BLUE}=== Available Disks ===${NC}"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep -E "disk"

echo
echo -e "${BLUE}=== Recommendations ===${NC}"

if [[ -d /sys/firmware/efi/efivars ]]; then
    echo "• Use GPT partition table"
    echo "• Create EFI System Partition (512MB, FAT32)"
    echo "• Install GRUB with: grub-install --target=x86_64-efi"
    echo "• Consider disabling Secure Boot during installation"
else
    echo "• Can use MBR or GPT partition table"
    echo "• No separate boot partition needed"
    echo "• Install GRUB with: grub-install --target=i386-pc /dev/sdX"
    echo "• Consider upgrading to UEFI if hardware supports it"
fi

echo
echo -e "${GREEN}Ready to run the installation script!${NC}"
