#!/bin/bash

# Fix Installation Issues Script
# This script helps fix common installation problems

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root"
        return 1
    fi
    return 0
}

# Fix partition detection issues
fix_partition_detection() {
    log "=== Fixing Partition Detection Issues ==="
    
    # Reload partition table
    log "Reloading partition tables..."
    partprobe 2>/dev/null || true
    
    # Wait for devices to settle
    sleep 3
    
    # Update device mapper
    if command -v dmsetup >/dev/null 2>&1; then
        log "Updating device mapper..."
        dmsetup mknodes 2>/dev/null || true
    fi
    
    # Trigger udev events
    log "Triggering udev events..."
    udevadm trigger 2>/dev/null || true
    udevadm settle 2>/dev/null || true
    
    success "Partition detection fixes applied"
}

# Fix mount issues
fix_mount_issues() {
    log "=== Fixing Mount Issues ==="
    
    local target_dir="/mnt"
    
    # Check if target directory exists
    if [[ ! -d "$target_dir" ]]; then
        log "Creating mount directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Unmount any existing mounts
    log "Cleaning up existing mounts..."
    umount -R "$target_dir" 2>/dev/null || true
    
    # Wait for unmount to complete
    sleep 2
    
    success "Mount issues fixes applied"
}

# Fix chroot preparation
fix_chroot_preparation() {
    log "=== Fixing Chroot Preparation ==="
    
    local chroot_dir="/mnt"
    
    if [[ ! -d "$chroot_dir" ]]; then
        error "Chroot directory $chroot_dir does not exist"
        return 1
    fi
    
    # Ensure essential directories exist
    log "Creating essential directories..."
    mkdir -p "$chroot_dir"/{dev,proc,sys,run}
    
    # Mount essential filesystems for chroot
    log "Mounting essential filesystems..."
    
    # Mount /dev
    if ! mountpoint -q "$chroot_dir/dev"; then
        mount --bind /dev "$chroot_dir/dev" || warn "Failed to bind mount /dev"
    fi
    
    # Mount /proc
    if ! mountpoint -q "$chroot_dir/proc"; then
        mount -t proc proc "$chroot_dir/proc" || warn "Failed to mount /proc"
    fi
    
    # Mount /sys
    if ! mountpoint -q "$chroot_dir/sys"; then
        mount -t sysfs sysfs "$chroot_dir/sys" || warn "Failed to mount /sys"
    fi
    
    # Mount /run
    if ! mountpoint -q "$chroot_dir/run"; then
        mount --bind /run "$chroot_dir/run" || warn "Failed to bind mount /run"
    fi
    
    success "Chroot preparation completed"
}

# Fix GRUB installation issues
fix_grub_issues() {
    log "=== Fixing GRUB Installation Issues ==="
    
    # Detect boot mode
    if [[ -d /sys/firmware/efi/efivars ]]; then
        local boot_mode="UEFI"
        log "Detected UEFI boot mode"
    else
        local boot_mode="BIOS"
        log "Detected BIOS boot mode"
    fi
    
    # Check if we're in chroot or live environment
    if [[ -f /etc/arch-release ]] && [[ -d /mnt/etc ]]; then
        log "Running from live environment, will use arch-chroot"
        local use_chroot=true
        local chroot_cmd="arch-chroot /mnt"
    else
        log "Running from installed system"
        local use_chroot=false
        local chroot_cmd=""
    fi
    
    if [[ "$boot_mode" == "UEFI" ]]; then
        log "Fixing UEFI GRUB installation..."
        
        # Ensure EFI directory exists
        if [[ "$use_chroot" == true ]]; then
            $chroot_cmd mkdir -p /boot/EFI
        else
            mkdir -p /boot/EFI
        fi
        
        # Reinstall GRUB
        if [[ "$use_chroot" == true ]]; then
            $chroot_cmd grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
            $chroot_cmd grub-mkconfig -o /boot/grub/grub.cfg
        else
            grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --recheck
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
    else
        log "Fixing BIOS GRUB installation..."
        
        # Get the disk device (remove partition number)
        local disk_device
        if [[ -f /proc/mounts ]]; then
            disk_device=$(awk '/\/ / {print $1}' /proc/mounts | head -1 | sed 's/[0-9]*$//')
        else
            error "Cannot determine disk device"
            return 1
        fi
        
        log "Installing GRUB to disk: $disk_device"
        
        # Reinstall GRUB
        if [[ "$use_chroot" == true ]]; then
            $chroot_cmd grub-install --target=i386-pc "$disk_device" --recheck
            $chroot_cmd grub-mkconfig -o /boot/grub/grub.cfg
        else
            grub-install --target=i386-pc "$disk_device" --recheck
            grub-mkconfig -o /boot/grub/grub.cfg
        fi
    fi
    
    success "GRUB fixes applied"
}

# Main menu
show_menu() {
    echo
    echo -e "${BLUE}=== Arch Linux Installation Issue Fixer ===${NC}"
    echo
    echo "1. Fix partition detection issues"
    echo "2. Fix mount issues"
    echo "3. Fix chroot preparation"
    echo "4. Fix GRUB installation issues"
    echo "5. Run all fixes"
    echo "0. Exit"
    echo
}

# Main function
main() {
    if ! check_root; then
        exit 1
    fi
    
    while true; do
        show_menu
        read -p "Select an option (0-5): " choice
        
        case $choice in
            1)
                fix_partition_detection
                ;;
            2)
                fix_mount_issues
                ;;
            3)
                fix_chroot_preparation
                ;;
            4)
                fix_grub_issues
                ;;
            5)
                log "Running all fixes..."
                fix_partition_detection
                fix_mount_issues
                fix_chroot_preparation
                fix_grub_issues
                success "All fixes completed"
                ;;
            0)
                log "Exiting..."
                exit 0
                ;;
            *)
                error "Invalid option. Please try again."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function
main "$@"
