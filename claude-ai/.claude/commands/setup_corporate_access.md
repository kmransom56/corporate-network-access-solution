# Setup Corporate Access Command

## Purpose
Configure secure access from corporate network to home server infrastructure

## Usage
`/setup_corporate_access [method] [service]`

## Arguments
- `$METHOD` - Access method (tailscale, zerotier, ssh_tunnel, reverse_proxy) [default: tailscale]
- `$SERVICE` - Specific service to configure (all, fortinet-manager, fortigate-dashboard, ai-network, mcp) [default: all]

## Command Template

```bash
# Corporate Network Access Setup
echo "🌐 Setting up corporate network access ($METHOD method for $SERVICE)..."

# 1. Validate current environment
echo "🔍 Validating current network environment..."

# Check Tailscale status
if ! tailscale status > /dev/null 2>&1; then
    echo "❌ ERROR: Tailscale not accessible on this server"
    echo "   Please ensure Tailscale is properly installed and authenticated"
    exit 1
fi

TAILSCALE_IP=$(tailscale ip -4)
echo "✅ Tailscale IP: $TAILSCALE_IP"

# Check for running services
ACTIVE_SERVICES=0
for project in "fortinet-manager" "ai-network-management-system" "fortigate-dashboard" "network-ai-troubleshooter"; do
    if [ -d "$project" ] && [ -f "$project/docker-compose.yml" ]; then
        cd "$project"
        if docker compose ps -q > /dev/null 2>&1; then
            running=$(docker compose ps --services --filter status=running | wc -l)
            if [ $running -gt 0 ]; then
                ACTIVE_SERVICES=$((ACTIVE_SERVICES + 1))
                echo "✅ $project: $running services running"
            else
                echo "⚠️  $project: Services not running"
            fi
        fi
        cd ..
    fi
done

echo "📊 Active network services: $ACTIVE_SERVICES"
echo ""

# 2. Method-specific setup
case "$METHOD" in
    "tailscale"|"")
        echo "🔧 Configuring Tailscale Corporate Access..."
        
        # Enable key expiry and device authorization settings
        echo "📋 Corporate Tailscale Checklist:"
        echo "   1. Share this server's Tailscale IP with your corporate device:"
        echo "      Tailscale IP: $TAILSCALE_IP"
        echo "   2. Install Tailscale on your corporate workstation:"
        echo "      - Windows: Download from tailscale.com/download/windows"
        echo "      - macOS: Download from tailscale.com/download/mac"
        echo "      - Linux: curl -fsSL https://tailscale.com/install.sh | sh"
        echo "   3. Authenticate using your existing account (kmransom52@)"
        echo "   4. Verify connectivity: ping $TAILSCALE_IP"
        echo ""
        
        # Configure service access points
        echo "🚀 Service Access URLs (via Tailscale):"
        
        if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "fortinet-manager" ]; then
            echo "   🛡️  Fortinet Manager:"
            echo "      Frontend: http://$TAILSCALE_IP:3002"
            echo "      API: http://$TAILSCALE_IP:3001"
            echo "      Backend: http://$TAILSCALE_IP:3000"
        fi
        
        if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "fortigate-dashboard" ]; then
            echo "   📊 FortiGate Dashboard:"
            echo "      Web UI: http://$TAILSCALE_IP:8000"
            echo "      API Docs: http://$TAILSCALE_IP:8000/docs"
        fi
        
        if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "ai-network" ]; then
            echo "   🤖 AI Network Management:"
            echo "      Neo4j Browser: http://$TAILSCALE_IP:7474"
            echo "      API: http://$TAILSCALE_IP:5000"
            echo "      Voice Interface: http://$TAILSCALE_IP:8080"
        fi
        
        if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "mcp" ]; then
            echo "   🔌 MCP Servers:"
            echo "      Fortinet MCP: Available via Claude Desktop/VS Code"
            echo "      SSH Access: ssh keith@$TAILSCALE_IP"
        fi
        
        # Generate nginx reverse proxy config for single-entry access
        echo ""
        echo "🔄 Generating reverse proxy configuration..."
        
        cat > /tmp/tailscale-corporate-proxy.conf << EOF
server {
    listen 80;
    server_name corporate-access;
    
    # Fortinet Manager
    location /fortinet-manager/ {
        proxy_pass http://localhost:3002/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # FortiGate Dashboard
    location /fortigate-dashboard/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    # AI Network Management
    location /ai-network/ {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    # Neo4j Browser
    location /neo4j/ {
        proxy_pass http://localhost:7474/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    
    # Health check endpoint
    location /health {
        return 200 "Corporate Access Gateway OK";
        add_header Content-Type text/plain;
    }
}
EOF
        
        echo "   📝 Nginx config saved to: /tmp/tailscale-corporate-proxy.conf"
        echo "   🔧 To enable: sudo cp /tmp/tailscale-corporate-proxy.conf /etc/nginx/sites-available/"
        echo "   🔄 Then: sudo nginx -t && sudo systemctl reload nginx"
        ;;
        
    "zerotier")
        echo "🌐 Configuring ZeroTier Corporate Access..."
        
        # Check ZeroTier status
        if ! systemctl is-active --quiet zerotier-one; then
            echo "❌ ERROR: ZeroTier service not running"
            echo "   Starting ZeroTier service..."
            sudo systemctl start zerotier-one
            sleep 3
        fi
        
        # Get ZeroTier node info
        if zerotier-cli info > /dev/null 2>&1; then
            NODE_ID=$(zerotier-cli info | awk '{print $3}')
            echo "✅ ZeroTier Node ID: $NODE_ID"
            
            echo "📋 Corporate ZeroTier Setup:"
            echo "   1. Create new ZeroTier network at my.zerotier.com"
            echo "   2. Note the Network ID (16-character hex)"
            echo "   3. Join network: sudo zerotier-cli join [NETWORK_ID]"
            echo "   4. Authorize this node ($NODE_ID) in ZeroTier Central"
            echo "   5. Install ZeroTier on corporate workstation"
            echo "   6. Join same network from corporate device"
            echo "   7. Test connectivity between devices"
        else
            echo "❌ ERROR: ZeroTier CLI not accessible"
            echo "   Try: sudo chmod +x /usr/sbin/zerotier-cli"
        fi
        ;;
        
    "ssh_tunnel")
        echo "🚇 Configuring SSH Tunnel Access..."
        
        # Ensure SSH is properly configured
        echo "🔑 SSH Configuration Check:"
        
        # Check if SSH is running
        if systemctl is-active --quiet ssh; then
            echo "✅ SSH service is running"
            
            # Check SSH configuration for security
            ssh_port=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}' || echo "22")
            echo "   SSH Port: $ssh_port"
            
            # Check for key authentication
            if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
                echo "✅ Password authentication disabled (key-based auth)"
            else
                echo "⚠️  Consider disabling password authentication"
            fi
            
            echo ""
            echo "📋 Corporate SSH Tunnel Setup:"
            echo "   1. From your corporate workstation, create SSH tunnel:"
            echo "      ssh -L 3000:localhost:3000 -L 8000:localhost:8000 -L 7474:localhost:7474 keith@$TAILSCALE_IP"
            echo "   2. Keep SSH session open in background"
            echo "   3. Access services via localhost on corporate machine:"
            echo "      - Fortinet Manager: http://localhost:3000"
            echo "      - FortiGate Dashboard: http://localhost:8000" 
            echo "      - Neo4j Browser: http://localhost:7474"
            echo ""
            echo "🤖 Automated tunnel script for corporate workstation:"
            
            cat > /tmp/corporate-tunnel.sh << 'EOF'
#!/bin/bash
# Corporate SSH Tunnel Script
# Run this on your corporate workstation

TAILSCALE_IP="$TAILSCALE_IP"
TUNNEL_PORTS="-L 3000:localhost:3000 -L 3001:localhost:3001 -L 3002:localhost:3002 -L 8000:localhost:8000 -L 7474:localhost:7474 -L 5000:localhost:5000"

echo "🚇 Establishing SSH tunnel to home server..."
echo "   Target: keith@$TAILSCALE_IP"
echo "   Ports: 3000,3001,3002,8000,7474,5000"
echo ""
echo "   Access URLs after connection:"
echo "   - Fortinet Manager: http://localhost:3002"
echo "   - FortiGate Dashboard: http://localhost:8000"
echo "   - Neo4j Browser: http://localhost:7474"
echo ""
echo "Press Ctrl+C to disconnect tunnel"
echo ""

ssh -N $TUNNEL_PORTS keith@$TAILSCALE_IP
EOF
            
            # Replace placeholder with actual IP
            sed -i "s/\$TAILSCALE_IP/$TAILSCALE_IP/g" /tmp/corporate-tunnel.sh
            chmod +x /tmp/corporate-tunnel.sh
            
            echo "   📝 Tunnel script saved to: /tmp/corporate-tunnel.sh"
            echo "   📋 Copy this script to your corporate workstation"
            
        else
            echo "❌ ERROR: SSH service not running"
            echo "   Start with: sudo systemctl start ssh"
        fi
        ;;
        
    "reverse_proxy")
        echo "🔄 Configuring Reverse Proxy Access..."
        
        # Install nginx if not present
        if ! command -v nginx > /dev/null; then
            echo "📦 Installing nginx..."
            sudo apt update && sudo apt install -y nginx
        fi
        
        # Create comprehensive reverse proxy config
        cat > /tmp/corporate-access-proxy.conf << EOF
upstream fortinet_manager {
    server 127.0.0.1:3002;
}

upstream fortigate_dashboard {
    server 127.0.0.1:8000;
}

upstream ai_network {
    server 127.0.0.1:5000;
}

upstream neo4j_browser {
    server 127.0.0.1:7474;
}

server {
    listen 80;
    server_name corporate-gateway;
    
    # Main dashboard - redirect to fortinet manager
    location / {
        return 301 /fortinet-manager/;
    }
    
    # Fortinet Manager (React frontend)
    location /fortinet-manager/ {
        proxy_pass http://fortinet_manager/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # FortiGate Dashboard (FastAPI)
    location /dashboard/ {
        proxy_pass http://fortigate_dashboard/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # AI Network Management
    location /ai/ {
        proxy_pass http://ai_network/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    # Neo4j Browser (for network topology)
    location /graph/ {
        proxy_pass http://neo4j_browser/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    # API endpoints
    location /api/ {
        # Route to appropriate backend based on path
        if (\$uri ~ ^/api/fortinet/) {
            proxy_pass http://127.0.0.1:3001/;
        }
        if (\$uri ~ ^/api/dashboard/) {
            proxy_pass http://127.0.0.1:8000/api/;
        }
    }
    
    # Health and status endpoints
    location /health {
        return 200 "Corporate Access Gateway - All Systems Operational\n\nAvailable Services:\n- /fortinet-manager/ - Device Management\n- /dashboard/ - Security Fabric Visualization\n- /ai/ - AI Network Management\n- /graph/ - Network Topology Browser\n";
        add_header Content-Type text/plain;
    }
    
    location /status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        allow 100.0.0.0/8;  # Allow Tailscale network
        deny all;
    }
}
EOF
        
        echo "   📝 Reverse proxy config created: /tmp/corporate-access-proxy.conf"
        echo "   🔧 To deploy: sudo cp /tmp/corporate-access-proxy.conf /etc/nginx/sites-available/"
        echo "   🔗 Enable: sudo ln -s /etc/nginx/sites-available/corporate-access-proxy.conf /etc/nginx/sites-enabled/"
        echo "   ✅ Test: sudo nginx -t"
        echo "   🔄 Apply: sudo systemctl reload nginx"
        echo ""
        echo "   🌐 Access via: http://$TAILSCALE_IP/health"
        ;;
esac

# 3. Security configuration
echo ""
echo "🔒 Security Configuration:"

# Firewall setup for corporate access
echo "   🛡️  Firewall recommendations:"
echo "   - Allow Tailscale subnet: sudo ufw allow from 100.64.0.0/10"
echo "   - Block direct internet access to services (optional):"
for port in 3000 3001 3002 8000 5000 7474; do
    echo "     sudo ufw deny $port"
done

# SSH key setup reminder
echo ""
echo "🔑 SSH Key Authentication (Recommended):"
echo "   1. Generate SSH key on corporate workstation (if not exists):"
echo "      ssh-keygen -t ed25519 -C 'corporate-workstation'"
echo "   2. Copy public key to this server:"
echo "      ssh-copy-id keith@$TAILSCALE_IP"
echo "   3. Test key authentication:"
echo "      ssh keith@$TAILSCALE_IP"

# 4. Update memory with corporate access setup
echo ""
echo "💾 Updating AI assistant memory..."

# Log the corporate access setup
echo "# Corporate Access Setup: $METHOD" >> .claude/memory/analysis_history.md
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> .claude/memory/analysis_history.md  
echo "Analysis Type: corporate_access_setup" >> .claude/memory/analysis_history.md
echo "Status: Configuration completed for $SERVICE services" >> .claude/memory/analysis_history.md
echo "Key Findings:" >> .claude/memory/analysis_history.md
echo "   - Method: $METHOD" >> .claude/memory/analysis_history.md
echo "   - Tailscale IP: $TAILSCALE_IP" >> .claude/memory/analysis_history.md
echo "   - Active Services: $ACTIVE_SERVICES" >> .claude/memory/analysis_history.md
echo "   - Corporate access configured for $SERVICE" >> .claude/memory/analysis_history.md
echo "Actions Taken: Corporate network access setup and configuration" >> .claude/memory/analysis_history.md
echo "---" >> .claude/memory/analysis_history.md
echo "" >> .claude/memory/analysis_history.md

# 5. Generate connection instructions
echo "✅ Corporate Access Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Install Tailscale on your corporate workstation"  
echo "2. Authenticate with your existing account (kmransom52@)"
echo "3. Test connectivity: ping $TAILSCALE_IP"
echo "4. Access services using the URLs provided above"
echo "5. Consider setting up SSH key authentication for security"
echo ""
echo "🆘 Troubleshooting:"
echo "   - If Tailscale blocked: Try ZeroTier alternative"
echo "   - If direct access blocked: Use SSH tunneling"
echo "   - If all VPNs blocked: Consider reverse SSH tunnel"
echo "   - Contact corporate IT for VPN policy clarification"
echo ""
echo "📊 Monitor connectivity with: tailscale status"
echo "🔍 Check service health with: /network_health_check"
```

## Integration with AI Assistant

### Automated Workflow
- This command integrates with the AI assistant's memory system
- Updates analysis history with corporate access configuration
- Provides troubleshooting steps for various corporate network scenarios
- Generates configuration files for immediate deployment

### Security Considerations  
- Emphasizes key-based SSH authentication
- Provides firewall configuration recommendations
- Considers corporate IT policy compliance
- Implements principle of least privilege access

This command provides a comprehensive solution for establishing secure corporate network access to your home-based network infrastructure management environment, with multiple fallback options for restrictive corporate networks.