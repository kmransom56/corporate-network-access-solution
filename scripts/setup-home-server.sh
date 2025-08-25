#!/bin/bash
# Corporate Network Access Solution - Home Server Setup
# This script prepares a home server for corporate network access

set -e

echo "🏠 Corporate Network Access Solution - Home Server Setup"
echo "========================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}❌ Please do not run this script as root${NC}"
    echo "   Run as regular user with sudo privileges"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install package if not exists
install_if_missing() {
    local package="$1"
    local command="${2:-$1}"
    
    if ! command_exists "$command"; then
        echo -e "${YELLOW}📦 Installing $package...${NC}"
        sudo apt update && sudo apt install -y "$package"
    else
        echo -e "${GREEN}✅ $package already installed${NC}"
    fi
}

echo -e "${BLUE}🔍 System Requirements Check${NC}"
echo "----------------------------------------"

# Check OS
if [ ! -f /etc/os-release ]; then
    echo -e "${RED}❌ Cannot determine OS version${NC}"
    exit 1
fi

source /etc/os-release
echo "✅ OS: $PRETTY_NAME"

# Check architecture
ARCH=$(uname -m)
echo "✅ Architecture: $ARCH"

# Check if Ubuntu/Debian
if [[ "$ID" != "ubuntu" && "$ID" != "debian" ]]; then
    echo -e "${YELLOW}⚠️  Warning: This script is optimized for Ubuntu/Debian${NC}"
    echo "   It may work on other distributions but is not tested"
fi

echo ""
echo -e "${BLUE}📦 Installing Required Packages${NC}"
echo "----------------------------------------"

# Update package list
echo "🔄 Updating package list..."
sudo apt update

# Install essential packages
install_if_missing "curl"
install_if_missing "wget"
install_if_missing "git"
install_if_missing "jq"
install_if_missing "ufw"
install_if_missing "htop"
install_if_missing "net-tools"
install_if_missing "dnsutils"

# Install Docker if not present
if ! command_exists "docker"; then
    echo -e "${YELLOW}🐳 Installing Docker...${NC}"
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo -e "${GREEN}✅ Docker installed${NC}"
    echo -e "${YELLOW}⚠️  Please log out and back in to use Docker without sudo${NC}"
else
    echo -e "${GREEN}✅ Docker already installed${NC}"
fi

# Install Docker Compose if not present
if ! command_exists "docker-compose" && ! docker compose version >/dev/null 2>&1; then
    echo -e "${YELLOW}🐳 Installing Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✅ Docker Compose already available${NC}"
fi

echo ""
echo -e "${BLUE}🌐 VPN Solutions Setup${NC}"
echo "----------------------------------------"

# Ask user which VPN solutions to install
echo "Which VPN solutions would you like to install?"
echo "1) Tailscale only (Recommended for most corporate environments)"
echo "2) ZeroTier only (Alternative for restricted networks)"
echo "3) Both Tailscale and ZeroTier (Maximum reliability)"
echo "4) Skip VPN installation (I'll install manually)"

read -p "Enter your choice (1-4): " vpn_choice

case $vpn_choice in
    1|3)
        echo -e "${YELLOW}🔧 Installing Tailscale...${NC}"
        if ! command_exists "tailscale"; then
            curl -fsSL https://tailscale.com/install.sh | sh
            echo -e "${GREEN}✅ Tailscale installed${NC}"
            echo -e "${BLUE}🔧 To set up Tailscale:${NC}"
            echo "   sudo tailscale up"
            echo "   tailscale ip -4"
        else
            echo -e "${GREEN}✅ Tailscale already installed${NC}"
        fi
        ;&
    2)
        if [ "$vpn_choice" = "2" ] || [ "$vpn_choice" = "3" ]; then
            echo -e "${YELLOW}🌐 Installing ZeroTier...${NC}"
            if ! command_exists "zerotier-cli"; then
                curl -s https://install.zerotier.com | sudo bash
                echo -e "${GREEN}✅ ZeroTier installed${NC}"
                echo -e "${BLUE}🔧 To set up ZeroTier:${NC}"
                echo "   1. Create network at https://my.zerotier.com"
                echo "   2. sudo zerotier-cli join [NETWORK-ID]"
                echo "   3. Authorize device in ZeroTier Central"
            else
                echo -e "${GREEN}✅ ZeroTier already installed${NC}"
            fi
        fi
        ;;
    4)
        echo -e "${BLUE}⏭️  Skipping VPN installation${NC}"
        ;;
    *)
        echo -e "${RED}❌ Invalid choice. Skipping VPN installation.${NC}"
        ;;
esac

echo ""
echo -e "${BLUE}🛡️  Firewall Configuration${NC}"
echo "----------------------------------------"

# Configure UFW firewall
if command_exists "ufw"; then
    echo -e "${YELLOW}🔧 Configuring UFW firewall...${NC}"
    
    # Enable UFW if not already enabled
    if ! sudo ufw status | grep -q "Status: active"; then
        sudo ufw --force enable
    fi
    
    # Allow SSH
    sudo ufw allow ssh comment 'SSH access'
    
    # Allow common network management ports (restrict to VPN networks later)
    for port in 3000 3001 3002 8000 5000 7474; do
        sudo ufw allow $port comment "Network management service"
    done
    
    # Allow VPN traffic
    if command_exists "tailscale"; then
        sudo ufw allow 41641/udp comment 'Tailscale'
        # Note: Tailscale subnet rules added after VPN setup
    fi
    
    if command_exists "zerotier-cli"; then
        sudo ufw allow 9993/udp comment 'ZeroTier'
        # Note: ZeroTier subnet rules added after VPN setup
    fi
    
    echo -e "${GREEN}✅ Basic firewall rules configured${NC}"
    echo -e "${YELLOW}⚠️  Additional VPN subnet rules will be added after VPN setup${NC}"
else
    echo -e "${YELLOW}⚠️  UFW not available, please configure firewall manually${NC}"
fi

echo ""
echo -e "${BLUE}📁 Directory Structure Setup${NC}"
echo "----------------------------------------"

# Create standard directory structure
mkdir -p ~/network-management/{projects,config,logs,backups}
mkdir -p ~/.claude/{memory,tasks,commands,agents}

echo -e "${GREEN}✅ Directory structure created${NC}"

echo ""
echo -e "${BLUE}🔧 System Configuration${NC}"
echo "----------------------------------------"

# Configure SSH for key-based authentication (if not already configured)
if [ ! -f ~/.ssh/authorized_keys ]; then
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo -e "${YELLOW}🔑 SSH directory created${NC}"
    echo -e "${BLUE}📝 To set up SSH key authentication:${NC}"
    echo "   1. Generate key on your workstation: ssh-keygen -t ed25519"
    echo "   2. Copy key to server: ssh-copy-id user@server-ip"
else
    echo -e "${GREEN}✅ SSH directory already configured${NC}"
fi

# Configure Git (if not already configured)
if ! git config --global user.email >/dev/null 2>&1; then
    echo -e "${YELLOW}📝 Git not configured. Please set up Git:${NC}"
    echo "   git config --global user.name 'Your Name'"
    echo "   git config --global user.email 'your.email@example.com'"
else
    echo -e "${GREEN}✅ Git already configured${NC}"
fi

echo ""
echo -e "${BLUE}📊 System Information${NC}"
echo "----------------------------------------"

# Display system information
echo "🖥️  System Info:"
echo "   Hostname: $(hostname)"
echo "   Local IP: $(hostname -I | awk '{print $1}')"
echo "   Public IP: $(curl -s ifconfig.me || echo 'Unable to detect')"
echo ""

# Display VPN information if available
if command_exists "tailscale"; then
    if tailscale status >/dev/null 2>&1; then
        TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "Not connected")
        echo "🔗 Tailscale IP: $TAILSCALE_IP"
    else
        echo "🔗 Tailscale: Installed but not configured"
    fi
fi

if command_exists "zerotier-cli"; then
    ZT_STATUS=$(sudo zerotier-cli info 2>/dev/null | awk '{print $4}' || echo "Unknown")
    echo "🌐 ZeroTier Status: $ZT_STATUS"
fi

echo ""
echo -e "${GREEN}✅ Home Server Setup Complete!${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}🎯 Next Steps:${NC}"
echo ""

if command_exists "tailscale"; then
    echo -e "${YELLOW}🔧 Configure Tailscale:${NC}"
    echo "   sudo tailscale up"
    echo "   tailscale ip -4"
    echo ""
fi

if command_exists "zerotier-cli"; then
    echo -e "${YELLOW}🌐 Configure ZeroTier:${NC}"
    echo "   1. Visit https://my.zerotier.com and create network"
    echo "   2. sudo zerotier-cli join [NETWORK-ID]"
    echo "   3. Authorize device in ZeroTier Central"
    echo ""
fi

echo -e "${YELLOW}🏢 Corporate Workstation Setup:${NC}"
echo "   1. Install same VPN client on corporate workstation"
echo "   2. Join same network/account"
echo "   3. Test connectivity between devices"
echo ""

echo -e "${YELLOW}🚀 Deploy Network Management Services:${NC}"
echo "   1. Set up your network management applications"
echo "   2. Configure services to bind to VPN interfaces"
echo "   3. Update firewall rules to restrict access to VPN networks"
echo ""

echo -e "${YELLOW}🤖 Set up AI Assistant:${NC}"
echo "   ./scripts/setup-claude-ai-assistant.sh"
echo ""

echo -e "${BLUE}📚 Documentation:${NC}"
echo "   See docs/ directory for detailed configuration guides"
echo ""

# Log setup completion
echo "$(date): Home server setup completed" >> ~/network-management/logs/setup.log

echo -e "${GREEN}🎉 Setup complete! Your home server is ready for corporate network access.${NC}"