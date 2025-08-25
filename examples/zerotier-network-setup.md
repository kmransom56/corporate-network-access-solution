# ZeroTier Network Setup Example

## Your Current ZeroTier Status ✅

**Your ZeroTier client is ready!**
- **Node ID**: 169a7c25c2 
- **Status**: ONLINE (connected to 4 planet controllers)
- **Service**: Active and healthy
- **Networks**: 0 (ready to join networks)

## Step 1: Create Your Corporate Network

### Via ZeroTier Central (Recommended Start)

1. **Visit**: https://my.zerotier.com
2. **Sign up/Login** with your preferred account
3. **Click**: "Create A Network"
4. **Copy the Network ID** (16-character hex, e.g., `a1b2c3d4e5f6g7h8`)

### Recommended Network Configuration

```
Network Name: Corporate-Access-Network
Description: Secure tunnel from corporate workstation to home server
Access Control: Private (requires authorization)
IPv4 Auto-Assign: 172.25.0.0/16 (private range, unlikely to conflict)
IPv6 Auto-Assign: Disabled (simplifies setup)
Broadcast: Enabled (for network discovery)
```

## Step 2: Join Network from Home Server

**Replace `YOUR-NETWORK-ID` with actual ID from ZeroTier Central:**

```bash
# Join the network
sudo zerotier-cli join YOUR-NETWORK-ID

# Verify join attempt
sudo zerotier-cli listnetworks

# You should see:
# 200 listnetworks <nwid> <name> <mac> <status> <type> <dev> <ZT assigned ips>
# YOUR-NETWORK-ID Corporate-Access-Network xx:xx:xx:xx:xx:xx ACCESS_DENIED PRIVATE zt+ -
```

The `ACCESS_DENIED` status is expected - you need to authorize the device next.

## Step 3: Authorize Your Home Server

1. **Return to ZeroTier Central** in your browser
2. **Click on your network** 
3. **Scroll to "Members" section**
4. **Find your device**: Look for Node ID `169a7c25c2`
5. **Check the "Auth" checkbox**
6. **Set Name**: "Home-Server-Ubuntu"
7. **Optional**: Assign specific IP like `172.25.0.10`

Within 30-60 seconds, your device will show as authorized.

## Step 4: Verify Network Assignment

```bash
# Check network status again
sudo zerotier-cli listnetworks

# Should now show:
# YOUR-NETWORK-ID Corporate-Access-Network xx:xx:xx:xx:xx:xx OK PRIVATE zt+ 172.25.x.x/16

# Check network interface
ip addr show zt+

# Test ZeroTier connectivity
ping 172.25.0.1  # Network gateway
```

## Step 5: Install on Corporate Workstation

### Windows
1. Download: https://download.zerotier.com/dist/ZeroTier%20One.msi
2. Install and run as Administrator
3. Right-click ZeroTier system tray icon → "Join Network"
4. Enter your Network ID
5. Return to ZeroTier Central to authorize the new device

### macOS
1. Download: https://download.zerotier.com/dist/ZeroTier%20One.pkg
2. Install and allow system extensions
3. Join network via menubar app or terminal: `sudo zerotier-cli join YOUR-NETWORK-ID`

### Linux (Corporate Workstation)
```bash
# Install ZeroTier
curl -s https://install.zerotier.com | sudo bash

# Join network
sudo zerotier-cli join YOUR-NETWORK-ID
```

## Step 6: Test Corporate → Home Connectivity

**From your corporate workstation:**

```bash
# Get your home server's ZeroTier IP
# (Check ZeroTier Central web interface or run on home server: ip addr show zt+)

HOME_SERVER_ZT_IP="172.25.0.10"  # Replace with actual IP

# Test basic connectivity
ping $HOME_SERVER_ZT_IP

# Test SSH access
ssh keith@$HOME_SERVER_ZT_IP

# Test web services
curl http://$HOME_SERVER_ZT_IP:8000/health     # FortiGate Dashboard
curl http://$HOME_SERVER_ZT_IP:3002/          # Fortinet Manager
curl http://$HOME_SERVER_ZT_IP:7474/browser/  # Neo4j Browser
```

## Step 7: Network Service Access

**Once connected via ZeroTier, access your services:**

| Service | URL | Description |
|---------|-----|-------------|
| **Fortinet Manager** | `http://172.25.0.10:3002` | Device management interface |
| **FortiGate Dashboard** | `http://172.25.0.10:8000` | Security topology visualization |
| **AI Network Management** | `http://172.25.0.10:5000` | Voice-controlled network ops |
| **Neo4j Browser** | `http://172.25.0.10:7474` | Network topology database |
| **SSH Access** | `ssh keith@172.25.0.10` | Direct server access |

## Troubleshooting Common Issues

### Issue: "ACCESS_DENIED" Status Persists
**Solution**: 
1. Verify you authorized the correct Node ID (169a7c25c2) in ZeroTier Central
2. Wait 60 seconds for authorization to propagate
3. Try leaving and rejoining: `sudo zerotier-cli leave YOUR-NETWORK-ID && sudo zerotier-cli join YOUR-NETWORK-ID`

### Issue: Can't Connect from Corporate Network  
**Solution**:
1. Check corporate firewall allows UDP port 9993 outbound
2. Try different ZeroTier relay nodes: `sudo zerotier-cli set YOUR-NETWORK-ID allowDefault=1`
3. Consider self-hosted controller if corporate policy blocks cloud services

### Issue: No ZeroTier IP Assigned
**Solution**:
1. Verify network has IPv4 Auto-Assign enabled
2. Check ZeroTier Central shows device as "ONLINE" 
3. Restart ZeroTier service: `sudo systemctl restart zerotier-one`

### Issue: Services Not Accessible via ZeroTier IP
**Solution**:
1. Verify services are bound to all interfaces (0.0.0.0), not just localhost (127.0.0.1)
2. Check local firewall: `sudo ufw status`
3. Test local access first: `curl http://localhost:8000/health`

## Corporate IT Approval Template

**Email Template for IT Security:**

```
Subject: ZeroTier VPN Software Installation Request - Network Management Access

Hello [IT Security Team],

I am requesting approval to install ZeroTier VPN client software on my corporate workstation for secure access to home-based network infrastructure that I manage as part of my professional responsibilities.

Business Justification:
- Remote management of client network infrastructure (812+ devices across 7 organizations)
- Secure access to network management tools and monitoring systems
- Compliance with client SLAs requiring 24/7 network management capabilities

Technical Details:
- Software: ZeroTier One (enterprise VPN solution)
- Protocol: Encrypted UDP over port 9993
- Architecture: Peer-to-peer encrypted tunneling
- Destination: Single home server (not internet browsing)
- Usage: Network management applications only

Security Features:
- End-to-end encryption (256-bit AES)
- Private network with device authorization required
- No internet routing or proxy capabilities
- Centralized access control and audit logging
- Corporate firewall compatible (outbound UDP only)

I can provide additional technical documentation or security reviews as needed.

Best regards,
[Your Name]
```

## Advanced Configuration

### Network Segmentation
Create separate ZeroTier networks for different purposes:

```bash
# Management network
sudo zerotier-cli join MGMT-NETWORK-ID      # 172.25.1.0/24

# Monitoring network  
sudo zerotier-cli join MONITOR-NETWORK-ID   # 172.25.2.0/24

# Client access network
sudo zerotier-cli join CLIENT-NETWORK-ID    # 172.25.3.0/24
```

### Custom Routes (Advanced)
Add routes in ZeroTier Central for accessing local network segments:

```
Route: 192.168.0.0/24 via 172.25.0.10
Description: Access home network devices via ZeroTier tunnel
```

## Self-Hosted Alternative

For enhanced corporate control, see `/docs/zerotier-complete-setup.md` for self-hosted ZeroTier controller deployment with Docker.

---

🎯 **Next Steps**: Your ZeroTier is configured and ready! Create a network at https://my.zerotier.com and join it using the commands above.

📞 **Support**: If you encounter issues, the corporate network access solution includes comprehensive troubleshooting guides and AI-powered network diagnostics.