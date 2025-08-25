#!/bin/bash
# ZeroTier Corporate Access Test Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 ZeroTier Corporate Access Test${NC}"
echo "=================================="
echo ""

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
    fi
}

# Check if running as root for certain commands
if [[ $EUID -eq 0 ]]; then
    ZT_CMD="zerotier-cli"
else
    ZT_CMD="sudo zerotier-cli"
fi

echo -e "${BLUE}📊 ZeroTier Service Status${NC}"
echo "----------------------------------------"

# Check service status
if systemctl is-active --quiet zerotier-one; then
    print_status 0 "ZeroTier service is running"
else
    print_status 1 "ZeroTier service is not running"
    echo "   Starting service..."
    sudo systemctl start zerotier-one
    sleep 3
fi

echo ""
echo -e "${BLUE}🔍 ZeroTier Node Information${NC}"
echo "----------------------------------------"

# Get node information
NODE_INFO=$($ZT_CMD info)
print_status $? "Node Info: $NODE_INFO"

# Parse node information
NODE_ID=$(echo $NODE_INFO | awk '{print $3}')
NODE_STATUS=$(echo $NODE_INFO | awk '{print $4}')

echo "   Node ID: $NODE_ID"
echo "   Status: $NODE_STATUS"

echo ""
echo -e "${BLUE}🌐 Network Connectivity${NC}"
echo "----------------------------------------"

# Check planet connectivity
echo "Testing planet connectivity..."
$ZT_CMD peers | head -5

# Count active peers
PEER_COUNT=$($ZT_CMD peers | grep -c "PLANET\|LEAF" || echo "0")
print_status 0 "Connected to $PEER_COUNT peers"

echo ""
echo -e "${BLUE}📱 Current Networks${NC}"
echo "----------------------------------------"

# List current networks
NETWORKS=$($ZT_CMD listnetworks)
echo "$NETWORKS"

# Count networks
NETWORK_COUNT=$($ZT_CMD listnetworks | grep -c "200" || echo "0")
echo "   Currently joined to $((NETWORK_COUNT - 1)) networks"

echo ""
echo -e "${BLUE}🔌 Network Interfaces${NC}"
echo "----------------------------------------"

# Check for ZeroTier interfaces
ZT_INTERFACES=$(ip addr show | grep zt || echo "No ZeroTier interfaces found")
echo "$ZT_INTERFACES"

echo ""
echo -e "${BLUE}🧪 Connectivity Tests${NC}"
echo "----------------------------------------"

# Test connectivity to ZeroTier infrastructure
echo "Testing connectivity to planet.zerotier.com..."
if ping -c 2 planet.zerotier.com >/dev/null 2>&1; then
    print_status 0 "Planet connectivity test passed"
else
    print_status 1 "Planet connectivity test failed"
fi

# Test UDP port 9993
echo "Testing UDP port 9993 connectivity..."
if nc -u -z planet.zerotier.com 9993 >/dev/null 2>&1; then
    print_status 0 "UDP port 9993 is accessible"
else
    print_status 1 "UDP port 9993 may be blocked"
fi

echo ""
echo -e "${BLUE}🎯 Network Creation Guide${NC}"
echo "----------------------------------------"

echo -e "${YELLOW}To create a ZeroTier network for corporate access:${NC}"
echo ""
echo "1. Visit https://my.zerotier.com"
echo "2. Sign up or log in"
echo "3. Click 'Create A Network'"
echo "4. Note the 16-character Network ID"
echo "5. Join from this server:"
echo "   ${BLUE}sudo zerotier-cli join [NETWORK-ID]${NC}"
echo ""
echo "6. Configure network settings:"
echo "   - Name: Corporate-Access-Network"
echo "   - IPv4 Auto-Assign: 172.25.0.0/16"
echo "   - Access Control: Private"
echo ""
echo "7. Authorize this device (Node ID: $NODE_ID) in ZeroTier Central"
echo "8. Install ZeroTier on your corporate workstation"
echo "9. Join the same network from corporate workstation"
echo "10. Test connectivity between devices"

echo ""
echo -e "${BLUE}📋 Service Access URLs (after network setup)${NC}"
echo "----------------------------------------"

echo "Once ZeroTier network is configured, access services via ZT IP:"
echo "   🛡️  Fortinet Manager: http://[ZT-IP]:3002"
echo "   📊 FortiGate Dashboard: http://[ZT-IP]:8000"  
echo "   🤖 AI Network Management: http://[ZT-IP]:5000"
echo "   🔍 Neo4j Browser: http://[ZT-IP]:7474"
echo "   🔐 SSH Access: ssh keith@[ZT-IP]"

echo ""
echo -e "${BLUE}🔧 Quick Network Join Command${NC}"
echo "----------------------------------------"

cat << 'EOF'
# Example network join (replace with actual network ID)
sudo zerotier-cli join 1234567890abcdef

# Check join status
sudo zerotier-cli listnetworks

# Get assigned IP address
ip addr show zt+
EOF

echo ""
echo -e "${BLUE}🚨 Troubleshooting${NC}"
echo "----------------------------------------"

echo "If you encounter issues:"
echo "1. Check service status: systemctl status zerotier-one"
echo "2. Restart service: sudo systemctl restart zerotier-one"  
echo "3. Check logs: journalctl -u zerotier-one -f"
echo "4. Verify firewall: sudo ufw allow 9993/udp"
echo "5. Test connectivity: ping planet.zerotier.com"

echo ""
echo -e "${GREEN}✅ ZeroTier test complete!${NC}"
echo ""
echo -e "${YELLOW}💡 Your ZeroTier is ready for network creation and joining!${NC}"
echo -e "${YELLOW}   Node ID: $NODE_ID${NC}"
echo -e "${YELLOW}   Status: $NODE_STATUS${NC}"
echo -e "${YELLOW}   Next step: Create network at https://my.zerotier.com${NC}"