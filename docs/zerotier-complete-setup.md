# ZeroTier Complete Setup Guide

## Current ZeroTier Status ✅

Your ZeroTier installation is working perfectly:
- **Node ID**: 169a7c25c2
- **Status**: ONLINE
- **Planet Controllers**: 4 connected with DIRECT connections
- **Service**: Active and running
- **Ready**: For network creation and joining

## 🌐 Standard ZeroTier Setup (Cloud-Managed)

### Step 1: Create Network at ZeroTier Central

1. **Visit ZeroTier Central**: https://my.zerotier.com
2. **Sign Up/Sign In**: Create account or log in
3. **Create Network**: Click "Create A Network"
4. **Note Network ID**: 16-character hex string (e.g., `1234567890abcdef`)

### Step 2: Configure Network Settings

**Network Configuration:**
```
Name: Corporate-Access-Network
Description: Secure access between corporate workstation and home server
Access Control: Private (recommended)
IPv4 Auto-Assign: 172.25.0.0/16
IPv6 Auto-Assign: Disabled (optional)
Broadcast: Enabled
Certificate: Default (managed)
```

**Advanced Settings:**
```
Multicast Limit: 32
Route: 0.0.0.0/0 via [home-server-zt-ip] (optional - for internet routing)
DNS: 8.8.8.8, 1.1.1.1
```

### Step 3: Join Network from Home Server

```bash
# Join the network (replace with your actual network ID)
sudo zerotier-cli join 1234567890abcdef

# Verify network joined
sudo zerotier-cli listnetworks

# Check assigned IP address
ip addr show | grep zt
```

### Step 4: Authorize Device in ZeroTier Central

1. **Go to Networks**: Click on your network in ZeroTier Central
2. **Find Your Device**: Look for node ID `169a7c25c2` in Members section
3. **Authorize**: Check the "Auth" checkbox
4. **Optional**: Assign specific IP address (e.g., 172.25.0.10)
5. **Add Description**: "Home Server - Ubuntu AI Code Server"

### Step 5: Configure Corporate Workstation

**Install ZeroTier Client:**
```bash
# Windows: Download from zerotier.com/download/windows
# macOS: Download from zerotier.com/download/mac
# Linux: curl -s https://install.zerotier.com | sudo bash

# Join same network
zerotier-cli join 1234567890abcdef
```

**Authorize in ZeroTier Central:**
1. Find corporate workstation node in Members
2. Check "Auth" checkbox
3. Assign IP (e.g., 172.25.0.20)
4. Add description: "Corporate Workstation"

### Step 6: Test Connectivity

```bash
# From corporate workstation, ping home server
ping 172.25.0.10

# From home server, ping corporate workstation  
ping 172.25.0.20

# Test service access
curl http://172.25.0.10:8000/health
```

## 🏢 Self-Hosted ZeroTier (Enhanced Corporate Control)

Self-hosting provides complete control over your ZeroTier network infrastructure, ideal for:
- **Enhanced Security**: No reliance on external cloud services
- **Corporate Compliance**: Full audit control and data sovereignty
- **Network Isolation**: Completely private network controller
- **Custom Features**: Advanced routing and security policies

### Self-Hosted Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Corporate       │    │ Self-Hosted     │    │ Home Server     │
│ Workstation     │◄──►│ ZT Controller   │◄──►│ (Your Server)   │
│                 │    │                 │    │                 │
│ ZT Client       │    │ ZTNCUI/Zero-UI  │    │ ZT Client       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Option 1: Docker-Based Self-Hosted Controller

#### Deploy ZTNCUI (Recommended)

```bash
# Create directory structure
mkdir -p ~/zerotier-controller/{ztncui,zt-data}
cd ~/zerotier-controller

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  zerotier-controller:
    image: zyclonedx/zerotier:latest
    container_name: zt-controller
    restart: unless-stopped
    volumes:
      - ./zt-data:/var/lib/zerotier-one
    ports:
      - "9993:9993/udp"
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    devices:
      - /dev/net/tun
    environment:
      - ZEROTIER_ONE_LOCAL_PHYS=eth0
      - ZEROTIER_ONE_USE_IPTABLES_NFT=0

  ztncui:
    image: keynetworks/ztncui
    container_name: ztncui
    restart: unless-stopped
    depends_on:
      - zerotier-controller
    ports:
      - "3443:3443"
    volumes:
      - ./ztncui:/opt/key-networks/ztncui/etc
    environment:
      - HTTPS_PORT=3443
      - NODE_ENV=production
      - ZTNCUI_PASSWD=your-secure-password-here
    links:
      - zerotier-controller:zt-controller
EOF

# Start the services
docker compose up -d

# Check status
docker compose ps
```

#### Access ZTNCUI Web Interface

```bash
# Access via browser
https://your-server-ip:3443

# Default credentials
Username: admin
Password: your-secure-password-here
```

### Option 2: Zero-UI Alternative Controller

```bash
# Alternative docker-compose with Zero-UI
cat > docker-compose.zero-ui.yml << 'EOF'
version: '3.8'

services:
  zerotier-controller:
    image: zyclonedx/zerotier:latest
    container_name: zt-controller
    restart: unless-stopped
    volumes:
      - ./zt-data:/var/lib/zerotier-one
    ports:
      - "9993:9993/udp"
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    devices:
      - /dev/net/tun

  zero-ui:
    image: dec0dos/zero-ui:latest
    container_name: zero-ui
    restart: unless-stopped
    depends_on:
      - zerotier-controller
    ports:
      - "4000:4000"
    volumes:
      - ./zero-ui:/app/backend/data
    environment:
      - ZU_CONTROLLER_ENDPOINT=http://zt-controller:9993
      - ZU_SECURE_HEADERS=true
      - ZU_DEFAULT_USERNAME=admin
      - ZU_DEFAULT_PASSWORD=your-secure-password
EOF

# Deploy Zero-UI version
docker compose -f docker-compose.zero-ui.yml up -d
```

### Self-Hosted Network Configuration

#### Create Corporate Network

1. **Access Web Interface**: https://your-server:3443 (ZTNCUI) or http://your-server:4000 (Zero-UI)
2. **Login**: Use admin credentials
3. **Create Network**:
   ```
   Network Name: Corporate-Access-Private
   Network ID: [Auto-generated]
   IPv4 Assignment: 10.147.20.0/24
   Private Network: Yes
   Enable Broadcast: Yes
   ```

#### Join Devices to Self-Hosted Network

```bash
# Get your controller's network ID from the web interface
NETWORK_ID="your-network-id-here"

# Join home server
sudo zerotier-cli join $NETWORK_ID

# Join corporate workstation (after installing ZeroTier client)
zerotier-cli join $NETWORK_ID
```

#### Configure Controller Address

```bash
# Point clients to your self-hosted controller
# Add to /var/lib/zerotier-one/planet file or use custom planet

# Or set environment variable
export ZT_OVERRIDE_PLANET=/path/to/your/planet.json
```

### Advanced Self-Hosted Features

#### Custom Planet Configuration

```bash
# Create custom planet for completely private network
# This ensures clients only connect to your controller

# Generate planet file
sudo zerotier-cli info  # Get your controller's node ID

# Create custom planet JSON
cat > custom-planet.json << 'EOF'
{
  "id": "your-controller-node-id",
  "objtype": "planet",
  "timestamp": 0,
  "roots": [
    {
      "identity": "your-controller-public-key",
      "stableEndpoints": ["your-server-ip/9993"]
    }
  ]
}
EOF
```

#### Network Segmentation

```bash
# Create multiple networks for different purposes
Network 1: Corporate-Management (172.25.1.0/24)
Network 2: Corporate-Servers (172.25.2.0/24)  
Network 3: Corporate-IoT (172.25.3.0/24)

# Configure routing between networks as needed
```

## 🔒 Corporate Security Configuration

### Network Security Rules

```bash
# Configure advanced rules in ZeroTier Central or self-hosted UI
# Allow only specific ports and protocols

# Example: Only allow network management ports
accept tcp/22;     # SSH
accept tcp/80;     # HTTP
accept tcp/443;    # HTTPS
accept tcp/8000;   # FortiGate Dashboard
accept tcp/3002;   # Fortinet Manager
accept tcp/7474;   # Neo4j
drop;              # Drop all other traffic
```

### Corporate Firewall Configuration

```bash
# Configure corporate firewall to allow ZeroTier
# Standard ZeroTier
allow outbound udp/9993

# Self-hosted controller
allow outbound udp/9993 to your-server-ip
```

### Monitoring and Logging

```bash
# Enable logging on self-hosted controller
docker compose logs -f zt-controller

# Monitor network activity
sudo zerotier-cli peers
sudo zerotier-cli listnetworks -j | jq

# Network diagnostics
zerotier-cli info
ping -c 4 planet.zerotier.com  # Test connectivity
```

## 🚀 Testing Your ZeroTier Setup

### Quick Test Script

```bash
#!/bin/bash
# ZeroTier Corporate Access Test

echo "🧪 ZeroTier Corporate Access Test"
echo "=================================="

# Check ZeroTier status
echo "📊 ZeroTier Status:"
sudo zerotier-cli info

# List networks
echo "🌐 Networks:"
sudo zerotier-cli listnetworks

# Check peers
echo "👥 Peers:"
sudo zerotier-cli peers | head -5

# Test network interfaces
echo "🔌 Network Interfaces:"
ip addr show | grep zt

# Test connectivity to ZeroTier infrastructure
echo "🌍 Connectivity Test:"
ping -c 2 planet.zerotier.com

echo "✅ ZeroTier test complete!"
```

### Service Access Test

```bash
# Test access to your network management services via ZeroTier
ZT_IP=$(ip addr show zt+ | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)

echo "🔗 ZeroTier IP: $ZT_IP"
echo "🧪 Testing service access..."

# Test each service
curl -s -o /dev/null -w "Fortinet Manager: %{http_code}\n" http://$ZT_IP:3002/
curl -s -o /dev/null -w "FortiGate Dashboard: %{http_code}\n" http://$ZT_IP:8000/health
curl -s -o /dev/null -w "Neo4j Browser: %{http_code}\n" http://$ZT_IP:7474/

echo "✅ Service access test complete!"
```

## 📊 ZeroTier vs Self-Hosted Comparison

| Feature | ZeroTier Central | Self-Hosted |
|---------|------------------|-------------|
| **Setup Complexity** | Easy | Moderate |
| **Corporate Control** | Limited | Complete |
| **Data Sovereignty** | No | Yes |
| **Custom Rules** | Basic | Advanced |
| **Maintenance** | None | Required |
| **Cost** | Free (up to 25 devices) | Infrastructure only |
| **Reliability** | High | Depends on setup |
| **Security** | Good | Excellent |

## 🎯 Recommendation

**For Your Corporate Network Access Solution:**

1. **Start with ZeroTier Central** - Quick setup and testing
2. **Evaluate Self-Hosted** - If corporate policy requires full control
3. **Hybrid Approach** - Use Central for testing, Self-hosted for production

Your current setup with Tailscale (primary) + ZeroTier (backup) provides excellent redundancy. The self-hosted option adds another layer of corporate control when needed.

Both approaches integrate seamlessly with your existing corporate network access solution!