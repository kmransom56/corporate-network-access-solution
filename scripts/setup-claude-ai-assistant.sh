#!/bin/bash
# Corporate Network Access Solution - Claude AI Assistant Setup
# This script configures the Claude AI assistant for network infrastructure management

set -e

echo "🤖 Corporate Network Access Solution - Claude AI Assistant Setup"
echo "================================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running from the correct directory
if [ ! -f "README.md" ] || [ ! -d "claude-ai" ]; then
    echo -e "${RED}❌ Please run this script from the corporate-network-access-solution directory${NC}"
    echo "   Current directory: $(pwd)"
    exit 1
fi

echo -e "${BLUE}📋 Claude AI Assistant Configuration${NC}"
echo "----------------------------------------"

# Check if Claude Code is installed
if ! command -v claude >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Claude Code CLI not detected${NC}"
    echo "   Please install Claude Code from: https://claude.ai/code"
    echo "   This script will configure the assistant files for when you install it"
    echo ""
fi

# Create .claude directory structure if it doesn't exist
echo -e "${BLUE}📁 Setting up AI Assistant directory structure...${NC}"

if [ ! -d ~/.claude ]; then
    mkdir -p ~/.claude/{memory,tasks,commands,agents}
    echo -e "${GREEN}✅ Created ~/.claude directory structure${NC}"
else
    echo -e "${GREEN}✅ ~/.claude directory already exists${NC}"
fi

# Copy AI assistant configuration files
echo -e "${BLUE}📄 Installing AI Assistant configuration files...${NC}"

# Copy memory files
if [ -d "claude-ai/memory" ]; then
    cp -r claude-ai/memory/* ~/.claude/memory/ 2>/dev/null || true
    echo -e "${GREEN}✅ Memory system configured${NC}"
fi

# Copy command files  
if [ -d "claude-ai/commands" ]; then
    cp -r claude-ai/commands/* ~/.claude/commands/ 2>/dev/null || true
    echo -e "${GREEN}✅ Automation commands installed${NC}"
fi

# Copy task files
if [ -d "claude-ai/tasks" ]; then
    cp -r claude-ai/tasks/* ~/.claude/tasks/ 2>/dev/null || true
    echo -e "${GREEN}✅ Task management configured${NC}"
fi

# Copy agent configurations
if [ -d "claude-ai/agents" ]; then
    cp -r claude-ai/agents/* ~/.claude/agents/ 2>/dev/null || true
    echo -e "${GREEN}✅ Specialized agents configured${NC}"
fi

# Copy main CLAUDE.md configuration
if [ -f "claude-ai/CLAUDE.md" ]; then
    cp claude-ai/CLAUDE.md ~/CLAUDE.md
    echo -e "${GREEN}✅ Main AI assistant configuration installed${NC}"
else
    echo -e "${YELLOW}⚠️  CLAUDE.md not found, creating basic configuration...${NC}"
    
    cat > ~/CLAUDE.md << 'EOF'
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 🤖 Personal AI Assistant Configuration

**You are my Network Infrastructure AI Chief of Staff.** Your primary role is to:

1. **Manage and orchestrate** my enterprise network infrastructure codebase
2. **Proactively maintain** project documentation and context
3. **Automate repetitive tasks** across multiple network projects
4. **Coordinate sub-agents** for specialized research and planning
5. **Self-organize** using the `.claude/` directory structure for persistent memory

### Assistant Behavioral Guidelines
- **Always be proactive** - suggest improvements and next steps
- **Maintain persistent memory** - use markdown files in `.claude/` for context
- **Delegate planning** to research agents, handle implementation yourself  
- **Track project state** across all network management applications
- **Prioritize security** - never expose credentials or sensitive network data
- **Think enterprise-scale** - solutions should handle large device environments

## 🧠 AI Assistant Memory System

### Memory Management Protocol
1. **Always read** `.claude/memory/project_context.md` at session start
2. **Update context** when project status changes are detected
3. **Log activities** in analysis_history.md for learning
4. **Track priorities** in current_priorities.md for focus
5. **Use commands** for consistent, repeatable workflows

## 🤖 Sub-Agent Coordination

### Command System Usage
**Standard Commands Available**:
- `/deploy_project [project] [env]` - Standardized deployments
- `/analyze_project [project] [type]` - Health, security, performance analysis
- `/setup_corporate_access [method]` - VPN configuration automation
- `/network_health_check [scope]` - Infrastructure monitoring

## 🎯 Proactive Assistant Behaviors

### Daily Operations
- **Monitor** current priorities and suggest next actions
- **Analyze** project health proactively (weekly automated checks)
- **Update** documentation when code changes are detected
- **Alert** about approaching deadlines or blocked tasks
- **Suggest** optimizations based on analysis patterns

### Decision Making Framework
1. **Security First** - Never compromise network security or expose credentials
2. **Enterprise Scale** - Solutions must handle large device environments
3. **Performance Priority** - Real-time responsiveness is critical for network operations
4. **Documentation Driven** - All changes require documentation updates
5. **Testing Required** - No production deployments without proper testing

## 📋 Session Initialization Checklist

**Every new Claude Code session should**:
1. ✅ Read `.claude/memory/project_context.md` for current state
2. ✅ Review `.claude/tasks/current_priorities.md` for focus areas  
3. ✅ Check for any new changes in main project directories
4. ✅ Suggest immediate actions based on priorities and project health
5. ✅ Offer to run project analysis or deployment commands as needed

This AI assistant configuration transforms Claude Code into your personal Network Infrastructure Chief of Staff, capable of managing complex enterprise-scale network projects with proactive intelligence and persistent memory.
EOF
    
    echo -e "${GREEN}✅ Basic CLAUDE.md configuration created${NC}"
fi

# Update memory files with current system information
echo -e "${BLUE}📊 Updating AI Assistant memory with current system...${NC}"

# Get current system information
HOSTNAME=$(hostname)
LOCAL_IP=$(hostname -I | awk '{print $1}')
TAILSCALE_IP="Not configured"
ZEROTIER_STATUS="Not configured"

# Check VPN status
if command -v tailscale >/dev/null 2>&1; then
    TAILSCALE_IP=$(tailscale ip -4 2>/dev/null || echo "Not connected")
fi

if command -v zerotier-cli >/dev/null 2>&1; then
    ZEROTIER_STATUS=$(sudo zerotier-cli info 2>/dev/null | awk '{print $4}' || echo "Unknown")
fi

# Create or update project context
cat > ~/.claude/memory/project_context.md << EOF
# Network Infrastructure Project Context

## Current Project State (Updated: $(date '+%Y-%m-%d'))

### System Information
- **Hostname**: $HOSTNAME
- **Local IP**: $LOCAL_IP
- **Tailscale IP**: $TAILSCALE_IP
- **ZeroTier Status**: $ZEROTIER_STATUS

### Active Development Focus
- **Primary**: Enterprise network device management
- **Secondary**: Corporate network access via VPN solutions
- **Innovation**: AI-powered network automation and troubleshooting

### Corporate Access Configuration
- **Home Network**: Local server infrastructure
- **VPN Solutions**: Tailscale (primary) + ZeroTier (backup)
- **Target**: Corporate workstation access through enterprise proxies
- **Security**: End-to-end encrypted VPN tunnels

### Infrastructure Overview
- **Container Strategy**: Docker Compose for all deployments
- **AI Integration**: Claude Code assistant with persistent memory
- **Network Scope**: Multi-vendor device management
- **Remote Access**: Dual VPN strategy for maximum reliability

### Current Challenges
1. **Corporate Network Access**: Secure remote access from corporate networks behind proxies
2. **VPN Reliability**: Ensuring consistent access through enterprise firewalls
3. **Service Management**: Centralized control of multiple network management applications
4. **Security Compliance**: Meeting corporate IT security requirements

### Opportunities for AI Assistant Automation
1. **VPN Management**: Automated VPN configuration and health monitoring
2. **Service Deployment**: Standardized deployment workflows
3. **Network Health**: Proactive monitoring and alerting
4. **Documentation**: Auto-update configuration guides
5. **Troubleshooting**: AI-powered network issue resolution

## Memory Management Strategy

This file serves as the central context for all AI assistant interactions. Update this file whenever:
- VPN configuration changes
- New network management services are added
- Corporate access requirements change
- System architecture is modified
- Security policies are updated

The AI assistant should reference this context for all decision-making and proactively suggest updates when system state changes are detected.
EOF

# Create current priorities file
cat > ~/.claude/tasks/current_priorities.md << EOF
# Current Network Infrastructure Priorities

## High Priority Tasks

### 1. Corporate Network Access Setup
**Status**: In Progress  
**Deadline**: Immediate  
**Problem**: Need secure access from corporate workstation to home server
**Solution Approach**: 
- Configure Tailscale as primary VPN solution
- Set up ZeroTier as backup option
- Test connectivity through corporate firewall
- Configure service access via VPN IPs

**Action Items**:
- [ ] Complete VPN client installation on corporate workstation
- [ ] Test connectivity to home server via VPN
- [ ] Configure network management services for VPN access
- [ ] Set up firewall rules for VPN-only access
- [ ] Document corporate access procedures

### 2. Service Configuration for Remote Access
**Status**: Planning  
**Deadline**: Next week  
**Problem**: Network management services need VPN-accessible configuration
**Solution Approach**:
- Configure services to bind to VPN interfaces
- Set up reverse proxy for single-entry access
- Implement proper authentication and authorization

**Action Items**:
- [ ] Review current service configurations
- [ ] Configure nginx reverse proxy
- [ ] Test service access via VPN IPs
- [ ] Implement SSL/TLS certificates
- [ ] Set up monitoring and health checks

## Medium Priority Tasks

### 3. AI Assistant Integration
**Status**: In Progress  
**Deadline**: Next 2 weeks  
**Problem**: Need AI-powered automation for network management
**Solution Approach**: Configure Claude AI assistant with network management commands

**Action Items**:
- [ ] Complete AI assistant memory configuration
- [ ] Test automation commands
- [ ] Create custom network management workflows
- [ ] Document AI assistant capabilities

### 4. Security Hardening
**Status**: Planning  
**Deadline**: Next month  
**Problem**: Corporate access requires enhanced security measures
**Solution Approach**: Implement comprehensive security controls

**Action Items**:
- [ ] Configure SSH key-based authentication
- [ ] Implement VPN-only access rules
- [ ] Set up access logging and monitoring
- [ ] Create incident response procedures

## Success Metrics

1. **Connectivity**: Successful VPN connection from corporate workstation
2. **Performance**: Sub-2 second response time for network management interfaces
3. **Security**: Zero unauthorized access attempts logged
4. **Reliability**: 99%+ uptime for critical network management services
5. **Automation**: AI assistant successfully handling routine management tasks

## AI Assistant Integration

This priority list should be:
- **Referenced** before starting any new configuration work
- **Updated** whenever VPN setup status changes
- **Used for planning** AI assistant automation tasks
- **Integrated** with network health monitoring workflows

The AI assistant should proactively:
- Monitor progress on corporate access setup
- Suggest optimizations for VPN configuration
- Alert about security considerations
- Update documentation based on configuration changes
EOF

# Set proper permissions
chmod -R 755 ~/.claude
find ~/.claude -name "*.md" -exec chmod 644 {} \;

echo -e "${GREEN}✅ AI Assistant memory updated with current system information${NC}"

# Create quick reference guide
cat > ~/.claude/quick-reference.md << 'EOF'
# Claude AI Assistant Quick Reference

## Available Commands

### Network Management
- `/network_health_check [scope]` - Check infrastructure health
- `/setup_corporate_access [method]` - Configure VPN access
- `/analyze_project [name] [type]` - Analyze project health/security
- `/deploy_project [name] [env]` - Deploy network services

### Memory Management  
- `/update_memory [type]` - Update assistant context
- Check `.claude/memory/project_context.md` for current state
- Review `.claude/tasks/current_priorities.md` for focus areas

### Automation
- AI assistant proactively monitors system health
- Persistent memory across Claude Code sessions
- Automated documentation updates
- Intelligent troubleshooting suggestions

## Directory Structure
```
~/.claude/
├── memory/           # Persistent context and learning
├── tasks/           # Current priorities and task management
├── commands/        # Automation command definitions
└── agents/          # Specialized agent configurations
```

## Getting Started
1. Install Claude Code from https://claude.ai/code
2. Open Claude Code in your project directory
3. The AI assistant will automatically initialize with your configuration
4. Use `/network_health_check` to verify system status
EOF

echo ""
echo -e "${BLUE}🧪 Testing AI Assistant Configuration${NC}"
echo "----------------------------------------"

# Test configuration files
echo "📋 Configuration Summary:"
echo "   Memory files: $(find ~/.claude/memory -name "*.md" | wc -l)"
echo "   Command files: $(find ~/.claude/commands -name "*.md" | wc -l)"
echo "   Task files: $(find ~/.claude/tasks -name "*.md" | wc -l)"
echo "   Agent files: $(find ~/.claude/agents -name "*.md" | wc -l)"
echo ""

# Display available commands
if [ -d ~/.claude/commands ]; then
    echo "🤖 Available AI Assistant Commands:"
    for cmd_file in ~/.claude/commands/*.md; do
        if [ -f "$cmd_file" ]; then
            cmd_name=$(basename "$cmd_file" .md)
            echo "   /$cmd_name"
        fi
    done
    echo ""
fi

echo -e "${GREEN}✅ Claude AI Assistant Setup Complete!${NC}"
echo "=============================================="
echo ""
echo -e "${BLUE}🎯 Next Steps:${NC}"
echo ""
echo -e "${YELLOW}1. Install Claude Code:${NC}"
echo "   Visit https://claude.ai/code and install the CLI"
echo ""
echo -e "${YELLOW}2. Initialize AI Assistant:${NC}"
echo "   cd ~/corporate-network-access-solution"
echo "   claude"
echo ""
echo -e "${YELLOW}3. Test AI Assistant:${NC}"
echo "   Ask: 'Run a network health check'"
echo "   Ask: 'What are my current priorities?'"
echo "   Ask: 'Help me set up corporate access'"
echo ""
echo -e "${YELLOW}4. Customize Configuration:${NC}"
echo "   Edit ~/.claude/memory/project_context.md with your specific setup"
echo "   Update ~/.claude/tasks/current_priorities.md with your priorities"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "   ~/.claude/quick-reference.md - Quick command reference"
echo "   docs/ directory - Detailed configuration guides"
echo ""

# Log setup completion
mkdir -p ~/network-management/logs
echo "$(date): Claude AI Assistant setup completed" >> ~/network-management/logs/setup.log

echo -e "${GREEN}🎉 Your AI Assistant is ready to manage your network infrastructure!${NC}"
echo ""
echo -e "${BLUE}💡 Pro Tip:${NC}"
echo "   The AI assistant will automatically remember your system state"
echo "   across sessions and proactively suggest improvements and automation."