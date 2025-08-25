# Setup ZeroTier Corporate Network Command

## Purpose
Configure ZeroTier network for corporate access to home server infrastructure

## Current Status
- **Node ID**: 169a7c25c2
- **Version**: 1.14.2  
- **Status**: ONLINE
- **Planet Connection**: Active (4 planet controllers connected)
- **Current Networks**: None joined

## Usage
`/setup_zerotier_corporate_network [network_name] [subnet]`

## Arguments
- `$NETWORK_NAME` - Name for the corporate access network [default: corporate-access]
- `$SUBNET` - IP subnet for the network [default: 172.25.0.0/16]

## Command Template

```bash
# ZeroTier Corporate Network Setup
echo "🌐 Setting up ZeroTier Corporate Access Network..."

NETWORK_NAME="${1:-corporate-access}"
SUBNET="${2:-172.25.0.0/16}"
NODE_ID="169a7c25c2"

echo "📋 ZeroTier Configuration:"
echo "   Node ID: $NODE_ID"
echo "   Network Name: $NETWORK_NAME"
echo "   Planned Subnet: $SUBNET"
echo ""

# 1. Check current ZeroTier status
echo "🔍 Checking ZeroTier service status..."
if ! systemctl is-active --quiet zerotier-one; then
    echo "❌ ERROR: ZeroTier service not running"
    echo "   Starting service: sudo systemctl start zerotier-one"
    sudo systemctl start zerotier-one
    sleep 3
fi

# Verify node is online
if sudo zerotier-cli info | grep -q "ONLINE"; then
    echo "✅ ZeroTier node is ONLINE"
    NODE_INFO=$(sudo zerotier-cli info)
    echo "   $NODE_INFO"
else
    echo "❌ ERROR: ZeroTier node is not online"
    exit 1
fi

# 2. Corporate Network Setup Instructions
echo ""
echo "📋 Corporate Access Network Setup Instructions:"
echo ""
echo "🌐 STEP 1: Create ZeroTier Network (Do this from any web browser)"
echo "   1. Go to: https://my.zerotier.com"
echo "   2. Sign in or create account"
echo "   3. Click 'Create A Network'"
echo "   4. Note the 16-character Network ID (example: 1234567890abcdef)"
echo "   5. Configure network settings:"
echo "      - Name: $NETWORK_NAME"
echo "      - Access Control: Private (recommended for corporate)"
echo "      - IPv4 Auto-Assign: $SUBNET"
echo "      - IPv6 Auto-Assign: Disable (optional)"
echo ""

echo "🏠 STEP 2: Join Network from Home Server (Run after creating network)"
echo "   Copy and run this command with your actual network ID:"
echo "   sudo zerotier-cli join [YOUR-16-CHAR-NETWORK-ID]"
echo "   Example: sudo zerotier-cli join 1234567890abcdef"
echo ""

echo "💼 STEP 3: Corporate Workstation Setup"
echo "   1. Install ZeroTier on your corporate workstation:"
echo "      - Windows: Download from zerotier.com/download"
echo "      - macOS: Download .pkg from zerotier.com/download"
echo "      - Linux: curl -s https://install.zerotier.com | sudo bash"
echo "   2. Join same network: zerotier-cli join [NETWORK-ID]"
echo "   3. Note the corporate workstation's node ID"
echo ""

echo "✅ STEP 4: Authorize Devices (Back in ZeroTier Central web UI)"
echo "   1. Go to Networks → Your Network"
echo "   2. Scroll to 'Members' section"
echo "   3. You'll see two devices:"
echo "      - $NODE_ID (this home server) - Check 'Auth' box"
echo "      - [Corporate Node ID] - Check 'Auth' box"
echo "   4. Optionally assign specific IP addresses"
echo "   5. Configure routing rules if needed"
echo ""

# 3. Service Configuration for ZeroTier Access
echo "🔧 STEP 5: Configure Services for ZeroTier Access"
echo ""
echo "   After network setup, your services will be accessible via ZeroTier IP:"
echo ""

# Generate service access template
cat > /tmp/zerotier-service-access.md << EOF
# ZeroTier Corporate Access - Service URLs

## Your ZeroTier Network Setup
- **Home Server Node**: $NODE_ID
- **Home Server ZT IP**: [Will be assigned after joining network]
- **Corporate Workstation ZT IP**: [Will be assigned after joining network]

## Service Access URLs (Replace ZT_IP with actual assigned IP)
- **Fortinet Manager Frontend**: http://ZT_IP:3002
- **Fortinet Manager API**: http://ZT_IP:3001  
- **Fortinet Manager Backend**: http://ZT_IP:3000
- **FortiGate Dashboard**: http://ZT_IP:8000
- **AI Network Management**: http://ZT_IP:5000
- **Neo4j Browser**: http://ZT_IP:7474
- **SSH Access**: ssh keith@ZT_IP

## Network Management Commands
\`\`\`bash
# Check ZeroTier status
sudo zerotier-cli info

# List joined networks  
sudo zerotier-cli listnetworks

# Check peer connections
sudo zerotier-cli peers

# Leave a network (if needed)
sudo zerotier-cli leave [NETWORK-ID]
\`\`\`

## Troubleshooting
- If services not accessible: Check firewall rules
- If connection fails: Verify both devices authorized in ZeroTier Central
- If slow performance: Check if direct P2P connection established
- Corporate firewall issues: ZeroTier uses UDP port 9993
EOF

echo "   📝 Service access guide saved to: /tmp/zerotier-service-access.md"
echo ""

# 4. Firewall configuration for ZeroTier
echo "🛡️  STEP 6: Firewall Configuration"
echo "   Configure UFW to allow ZeroTier subnet access:"
echo ""
echo "   # Allow ZeroTier network traffic"
echo "   sudo ufw allow from $SUBNET"
echo "   sudo ufw allow 9993/udp comment 'ZeroTier'"
echo ""
echo "   # Optional: Block direct internet access to services"
echo "   # (forces access only via VPN)"
for port in 3000 3001 3002 8000 5000 7474; do
    echo "   sudo ufw deny $port comment 'Block direct access to $port'"
done

# 5. Comparison with Tailscale
echo ""
echo "📊 STEP 7: ZeroTier vs Tailscale Comparison for Your Setup"
echo ""
echo "   Tailscale (Current): 100.123.10.72 - ✅ ACTIVE"
echo "   ZeroTier (New): [IP to be assigned] - 🔧 SETUP REQUIRED"
echo ""
echo "   Use Cases:"
echo "   - **Tailscale**: Primary corporate access (better Zscaler compatibility)"
echo "   - **ZeroTier**: Backup access method (different protocol)"
echo "   - **Both**: Maximum reliability with dual VPN redundancy"
echo ""

# 6. Security considerations
echo "🔒 STEP 8: Security Best Practices"
echo ""
echo "   Corporate Access Security:"
echo "   1. Use SSH key authentication (not passwords)"
echo "   2. Keep ZeroTier clients updated on both ends"
echo "   3. Review ZeroTier network member list regularly"
echo "   4. Consider IP whitelisting in ZeroTier network rules"
echo "   5. Monitor access logs for unusual activity"
echo ""
echo "   Network Rules (Advanced):"
echo "   - Default: Allow all traffic between network members"
echo "   - Restrictive: Create rules to allow only specific ports/services"
echo "   - Logging: Enable flow rules logging for security monitoring"
echo ""

# 7. Testing and validation
echo "✅ STEP 9: Testing Connectivity"
echo ""
echo "   After completing setup, test with these commands:"
echo ""
echo "   From Corporate Workstation:"
echo "   1. ping [HOME-SERVER-ZT-IP]           # Test basic connectivity"
echo "   2. ssh keith@[HOME-SERVER-ZT-IP]     # Test SSH access"
echo "   3. curl http://[HOME-SERVER-ZT-IP]:8000/health  # Test service access"
echo ""
echo "   From Home Server:"
echo "   1. ping [CORPORATE-WORKSTATION-ZT-IP]  # Test reverse connectivity"
echo "   2. sudo zerotier-cli peers              # Check peer status"
echo ""

# 8. Integration with existing Tailscale
echo "🔗 STEP 10: Dual VPN Strategy"
echo ""
echo "   Running Both Tailscale + ZeroTier:"
echo "   ✅ Compatible: Both can run simultaneously"
echo "   ✅ Different Subnets: Tailscale (100.x.x.x) + ZeroTier (172.25.x.x)"
echo "   ✅ Redundancy: If one fails, other provides backup access"
echo "   ✅ Protocol Diversity: WireGuard vs custom UDP"
echo ""
echo "   Corporate Access Priority:"
echo "   1. Try Tailscale first (100.123.10.72) - usually best performance"  
echo "   2. Fall back to ZeroTier if Tailscale blocked"
echo "   3. Use SSH tunneling as last resort"
echo ""

# 9. Generate quick setup script
cat > /tmp/zerotier-quick-join.sh << 'EOF'
#!/bin/bash
# ZeroTier Corporate Network Quick Join Script
# Usage: ./zerotier-quick-join.sh [NETWORK-ID]

if [ $# -eq 0 ]; then
    echo "Usage: $0 [NETWORK-ID]"
    echo "Example: $0 1234567890abcdef"
    exit 1
fi

NETWORK_ID="$1"

echo "🌐 Joining ZeroTier network: $NETWORK_ID"
sudo zerotier-cli join "$NETWORK_ID"

echo "⏳ Waiting for network connection..."
sleep 5

echo "📊 Network Status:"
sudo zerotier-cli listnetworks

echo "🔍 Node Information:"
sudo zerotier-cli info

echo ""
echo "✅ Network join complete!"
echo "🚨 IMPORTANT: You must authorize this device in ZeroTier Central"
echo "   1. Go to https://my.zerotier.com"
echo "   2. Click on your network"  
echo "   3. Find device 169a7c25c2 in Members section"
echo "   4. Check the 'Auth' checkbox"
echo "   5. Note the assigned IP address"
echo ""
echo "🧪 Test connectivity after authorization:"
echo "   ping [OTHER-DEVICE-ZT-IP]"
EOF

chmod +x /tmp/zerotier-quick-join.sh
echo "   📝 Quick join script saved to: /tmp/zerotier-quick-join.sh"

# 10. Update AI assistant memory
echo ""
echo "💾 Updating AI assistant memory with ZeroTier configuration..."

# Log the ZeroTier setup
echo "# ZeroTier Corporate Network Setup" >> .claude/memory/analysis_history.md
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> .claude/memory/analysis_history.md
echo "Analysis Type: zerotier_corporate_setup" >> .claude/memory/analysis_history.md
echo "Status: ZeroTier configuration prepared for corporate access" >> .claude/memory/analysis_history.md
echo "Key Findings:" >> .claude/memory/analysis_history.md
echo "   - ZeroTier Node ID: $NODE_ID" >> .claude/memory/analysis_history.md
echo "   - Service Status: ONLINE" >> .claude/memory/analysis_history.md
echo "   - Planet Controllers: Connected" >> .claude/memory/analysis_history.md
echo "   - Current Networks: None (setup required)" >> .claude/memory/analysis_history.md
echo "   - Planned Subnet: $SUBNET" >> .claude/memory/analysis_history.md
echo "Actions Taken: ZeroTier corporate access configuration guide created" >> .claude/memory/analysis_history.md
echo "---" >> .claude/memory/analysis_history.md
echo "" >> .claude/memory/analysis_history.md

echo "✅ ZeroTier Corporate Access Setup Complete!"
echo ""
echo "📋 Summary of Next Actions:"
echo "1. 🌐 Create network at https://my.zerotier.com"
echo "2. 🏠 Join network: sudo zerotier-cli join [NETWORK-ID]"
echo "3. 💼 Install ZeroTier on corporate workstation"
echo "4. 🔗 Join same network from corporate device"
echo "5. ✅ Authorize both devices in ZeroTier Central"
echo "6. 🧪 Test connectivity and service access"
echo ""
echo "📊 Your dual VPN setup will provide:"
echo "   - Tailscale: Primary corporate access (100.123.10.72)"
echo "   - ZeroTier: Backup corporate access ([to be assigned])"
echo "   - Maximum reliability for remote network management"
```

## Integration with AI Assistant

### Automated Corporate Access Strategy
This ZeroTier setup complements your existing Tailscale infrastructure:

1. **Primary Access**: Tailscale (100.123.10.72) - Best Zscaler compatibility
2. **Backup Access**: ZeroTier (new network) - Alternative protocol
3. **Emergency Access**: SSH tunneling via either VPN
4. **Redundancy**: Dual VPN ensures always-available corporate access

### Memory Integration
- Logs ZeroTier configuration in AI assistant memory
- Updates corporate access analysis with dual-VPN strategy
- Provides troubleshooting guidance for both Tailscale and ZeroTier

### Service Access Optimization
Both VPN solutions provide access to:
- fortinet-manager (React + Node.js)
- fortigate-dashboard (FastAPI)
- ai-network-management-system (Neo4j + Python)
- network-ai-troubleshooter (FastAPI + Neo4j)
- MCP servers for AI integration

This dual VPN strategy maximizes your chances of successful corporate network access while providing redundancy for critical network management operations.