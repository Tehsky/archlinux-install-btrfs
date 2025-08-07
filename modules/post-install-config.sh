#!/bin/bash

# Post-Installation Configuration Script for Arch Linux
# This script handles post-installation configuration and optimization

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root. Please run as a regular user."
    exit 1
fi

echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              Arch Linux Post-Installation Setup              ║${NC}"
echo -e "${CYAN}║                Configuration and Optimization                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo

# Function to configure AUR helper
configure_aur_helper() {
    log "Setting up AUR helper (yay)..."
    
    if command -v yay &> /dev/null; then
        log "yay is already installed"
        return 0
    fi
    
    # Install base-devel if not already installed
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Clone and install yay
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    
    log "yay AUR helper installed successfully"
}

# Function to configure Pacman
configure_pacman() {
    log "Configuring Pacman..."
    
    # Backup original pacman.conf
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup
    
    # Enable parallel downloads
    sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/' /etc/pacman.conf
    
    # Enable color output
    sudo sed -i 's/#Color/Color/' /etc/pacman.conf
    
    # Enable verbose package lists
    sudo sed -i 's/#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
    
    # Add ILoveCandy for Pac-Man progress bar
    sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
    
    # Enable multilib repository (for 32-bit support)
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
        log "Enabled multilib repository"
    fi
    
    # Update package database
    sudo pacman -Sy
    
    log "Pacman configuration completed"
}

# Function to configure mirrors
configure_mirrors() {
    log "Configuring mirrors with reflector..."
    
    # Install reflector if not already installed
    sudo pacman -S --needed --noconfirm reflector
    
    # Backup original mirrorlist
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    
    # Generate new mirrorlist
    sudo reflector --country China,Japan,Korea,Singapore,Taiwan \
                   --age 12 \
                   --protocol https \
                   --sort rate \
                   --save /etc/pacman.d/mirrorlist
    
    # Enable reflector timer for automatic updates
    sudo systemctl enable reflector.timer
    
    log "Mirror configuration completed"
}

# Function to install essential packages
install_essential_packages() {
    log "Installing essential packages..."
    
    # System utilities
    local system_packages=(
        "htop"              # Process viewer
        "neofetch"          # System information
        "tree"              # Directory tree viewer
        "unzip"             # Archive extraction
        "zip"               # Archive creation
        "wget"              # Download utility
        "curl"              # Transfer utility
        "git"               # Version control
        "vim"               # Text editor
        "nano"              # Simple text editor
        "bash-completion"   # Bash auto-completion
        "man-db"            # Manual pages
        "man-pages"         # Manual pages
        "which"             # Command location
        "lsof"              # List open files
        "rsync"             # File synchronization
        "openssh"           # SSH client/server
    )
    
    # Development tools
    local dev_packages=(
        "base-devel"        # Development tools
        "python"            # Python interpreter
        "python-pip"        # Python package manager
        "nodejs"            # Node.js runtime
        "npm"               # Node package manager
    )
    
    # Media and graphics
    local media_packages=(
        "firefox"           # Web browser
        "vlc"               # Media player
        "gimp"              # Image editor
        "libreoffice-fresh" # Office suite
    )
    
    # Install packages
    sudo pacman -S --needed --noconfirm "${system_packages[@]}"
    
    # Ask user for additional packages
    echo
    info "Would you like to install additional packages?"
    read -p "Install development tools? (y/N): " install_dev
    if [[ "$install_dev" =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed --noconfirm "${dev_packages[@]}"
    fi
    
    read -p "Install media and office applications? (y/N): " install_media
    if [[ "$install_media" =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed --noconfirm "${media_packages[@]}"
    fi
    
    log "Essential packages installation completed"
}

# Function to configure shell
configure_shell() {
    log "Configuring shell environment..."
    
    # Install zsh and oh-my-zsh
    read -p "Would you like to install and configure Zsh with Oh My Zsh? (y/N): " install_zsh
    if [[ "$install_zsh" =~ ^[Yy]$ ]]; then
        sudo pacman -S --needed --noconfirm zsh zsh-completions
        
        # Install Oh My Zsh
        if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
            sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
        
        # Install popular plugins
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || true
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || true
        
        # Configure .zshrc
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        
        # Change default shell
        chsh -s /usr/bin/zsh
        
        log "Zsh and Oh My Zsh configured successfully"
    fi
    
    # Configure aliases
    cat >> ~/.bashrc << 'EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -R'
alias autoremove='sudo pacman -Rns $(pacman -Qtdq)'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias histg='history | grep'
alias myip='curl http://ipecho.net/plain; echo'
alias logs='sudo journalctl -f'
alias reboot='sudo systemctl reboot'
alias poweroff='sudo systemctl poweroff'
EOF

    if [[ -f ~/.zshrc ]]; then
        cat >> ~/.zshrc << 'EOF'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -R'
alias autoremove='sudo pacman -Rns $(pacman -Qtdq)'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias ps='ps auxf'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias histg='history | grep'
alias myip='curl http://ipecho.net/plain; echo'
alias logs='sudo journalctl -f'
alias reboot='sudo systemctl reboot'
alias poweroff='sudo systemctl poweroff'
EOF
    fi
    
    log "Shell configuration completed"
}

# Function to configure Git
configure_git() {
    log "Configuring Git..."
    
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    
    if [[ -n "$git_username" && -n "$git_email" ]]; then
        git config --global user.name "$git_username"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        git config --global core.editor vim
        git config --global pull.rebase false
        
        log "Git configured with username: $git_username and email: $git_email"
    else
        warn "Git configuration skipped"
    fi
}

# Function to configure firewall
configure_firewall() {
    log "Configuring firewall (UFW)..."
    
    # Install UFW
    sudo pacman -S --needed --noconfirm ufw
    
    # Configure UFW
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    
    # Enable UFW
    sudo ufw --force enable
    sudo systemctl enable ufw
    
    log "Firewall configured and enabled"
}

# Function to optimize system performance
optimize_system() {
    log "Optimizing system performance..."
    
    # Configure swappiness
    echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swappiness.conf
    
    # Configure I/O scheduler for SSDs
    if lsblk -d -o name,rota | grep -q "0$"; then
        echo 'ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"' | sudo tee /etc/udev/rules.d/60-ioschedulers.rules
        log "Configured I/O scheduler for SSD"
    fi
    
    # Enable TRIM for SSDs
    sudo systemctl enable fstrim.timer
    
    # Configure journal size limit
    sudo sed -i 's/#SystemMaxUse=/SystemMaxUse=100M/' /etc/systemd/journald.conf
    
    log "System optimization completed"
}

# Function to configure fonts
configure_fonts() {
    log "Installing and configuring fonts..."
    
    # Install essential fonts
    sudo pacman -S --needed --noconfirm \
        ttf-dejavu \
        ttf-liberation \
        noto-fonts \
        noto-fonts-cjk \
        noto-fonts-emoji \
        ttf-roboto \
        ttf-opensans
    
    # Install popular fonts from AUR
    if command -v yay &> /dev/null; then
        read -p "Install additional fonts from AUR? (y/N): " install_aur_fonts
        if [[ "$install_aur_fonts" =~ ^[Yy]$ ]]; then
            yay -S --needed --noconfirm \
                ttf-ms-fonts \
                ttf-vista-fonts \
                ttf-consolas-ligaturized
        fi
    fi
    
    # Refresh font cache
    fc-cache -fv
    
    log "Font configuration completed"
}

# Main execution
main() {
    log "Starting post-installation configuration..."
    
    # Update system first
    log "Updating system packages..."
    sudo pacman -Syu --noconfirm
    
    # Run configuration functions
    configure_pacman
    configure_mirrors
    configure_aur_helper
    install_essential_packages
    configure_shell
    configure_git
    configure_firewall
    optimize_system
    configure_fonts
    
    echo
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                 Configuration Completed!                     ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo
    log "Post-installation configuration completed successfully!"
    echo
    info "Recommended next steps:"
    echo "1. Reboot the system to apply all changes"
    echo "2. Install your preferred desktop environment"
    echo "3. Configure additional applications as needed"
    echo "4. Set up backups and snapshots"
    echo
    warn "Please reboot your system to ensure all changes take effect."
    
    read -p "Would you like to reboot now? (y/N): " reboot_now
    if [[ "$reboot_now" =~ ^[Yy]$ ]]; then
        sudo systemctl reboot
    fi
}

# Run main function
main "$@"
