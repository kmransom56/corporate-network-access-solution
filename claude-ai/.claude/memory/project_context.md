# Network Infrastructure Project Context

## Current Project State (Updated: 2025-08-25)

### Active Development Focus
- **Primary**: Enterprise Fortinet device management across multiple projects
- **Secondary**: AI-powered network automation and troubleshooting
- **Innovation**: Voice-controlled network operations for restaurant chains

### Key Project Status

#### 🔥 Production Systems
1. **fortinet-manager/** - ACTIVE DEVELOPMENT
   - Status: Material-UI v7 React + Node.js backend
   - Scope: Professional FortiGate/FortiSwitch management platform
   - Key Features: 246+ API endpoints, MongoDB/Redis backend
   - Next Priority: Real-time dashboard enhancements

2. **ai-network-management-system/** - PRODUCTION
   - Status: Managing 812+ devices across 7 organizations  
   - Scope: Voice-controlled enterprise network automation
   - Key Features: Neo4j topology, AutoGen multi-agent coordination
   - Next Priority: Scaling to additional restaurant locations

3. **mcp_server/fortinet/** - ACTIVE
   - Status: AI-native Fortinet device control via MCP protocol
   - Scope: Complete FortiGate API integration for Claude Desktop
   - Next Priority: Enhanced error handling and device discovery

#### 🚀 Development Systems  
1. **fortigate-dashboard/** - ENHANCEMENT PHASE
   - Status: Security Fabric visualization with FastAPI
   - Next Priority: Performance optimization and real-time updates

2. **network-ai-troubleshooter/** - STABLE
   - Status: AI diagnostics with Neo4j graph database
   - Next Priority: Integration with main management systems

### Infrastructure Overview
- **Total Projects**: 40+ in repositories/ directory
- **Database Stack**: Neo4j (topology), MongoDB (config), Redis (cache), PostgreSQL (audit)
- **Container Strategy**: Docker Compose for all deployments
- **AI Integration**: OpenAI, Ollama, vLLM with AutoGen coordination
- **Network Scope**: Multi-vendor (Fortinet primary, Cisco Meraki secondary)

### Current Challenges
1. **Integration Complexity**: Multiple database systems need better coordination
2. **Scale Management**: 812+ devices require more efficient batch operations
3. **Real-time Performance**: Dashboard updates need optimization
4. **Documentation Debt**: Several projects need updated READMEs
5. **Corporate Network Access**: Secure remote access from corporate networks behind Zscaler

### Opportunities for AI Assistant Automation
1. **Code Generation**: Consistent API endpoint patterns across projects
2. **Documentation**: Auto-update project READMEs based on code changes
3. **Testing**: Generate comprehensive test suites for new features
4. **Deployment**: Streamline Docker compose configurations
5. **Monitoring**: Proactive alerting on project health issues

## Memory Management Strategy

This file serves as the central context for all AI assistant interactions. Update this file whenever:
- New projects are added or status changes
- Architecture decisions are made
- Development priorities shift
- Integration challenges are identified
- Performance bottlenecks are discovered

The AI assistant should reference this context for all decision-making and proactively suggest updates when project state changes are detected.