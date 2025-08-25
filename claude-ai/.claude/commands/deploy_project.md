# Deploy Project Command

## Purpose
Standardized deployment workflow for network infrastructure projects

## Usage
`/deploy_project [project_name] [environment]`

## Arguments
- `$PROJECT_NAME` - Name of project directory (e.g., fortinet-manager, fortigate-dashboard)
- `$ENVIRONMENT` - Target environment (dev, staging, prod) [default: dev]

## Command Template

```bash
# Network Infrastructure Project Deployment
echo "🚀 Deploying $PROJECT_NAME to $ENVIRONMENT environment..."

# 1. Validate project exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo "❌ Error: Project directory '$PROJECT_NAME' not found"
    exit 1
fi

cd "$PROJECT_NAME"

# 2. Check for required files
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: docker-compose.yml not found in $PROJECT_NAME"
    exit 1
fi

# 3. Environment setup
if [ -f ".env.example" ] && [ ! -f ".env" ]; then
    echo "📋 Creating .env from template..."
    cp .env.example .env
    echo "⚠️  Please review and update .env file before continuing"
fi

# 4. Pre-deployment checks
echo "🔍 Running pre-deployment checks..."

# Check Docker daemon
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker daemon not running"
    exit 1
fi

# Check for existing containers
CONTAINERS=$(docker compose ps -q)
if [ ! -z "$CONTAINERS" ]; then
    echo "🔄 Stopping existing containers..."
    docker compose down
fi

# 5. Build and deploy
echo "🏗️  Building containers..."
docker compose build --no-cache

echo "🚀 Starting services..."
docker compose up -d

# 6. Health checks
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check service health
docker compose ps

# 7. Access information
echo ""
echo "✅ Deployment complete!"
echo "📊 Project: $PROJECT_NAME"
echo "🌍 Environment: $ENVIRONMENT"
echo "🔗 Access URLs:"

# Extract port mappings from docker-compose
if command -v yq > /dev/null 2>&1; then
    yq eval '.services.*.ports[]' docker-compose.yml | while read port; do
        if [[ $port =~ ^([0-9]+):([0-9]+)$ ]]; then
            echo "   http://localhost:${BASH_REMATCH[1]}"
        fi
    done
else
    echo "   Check docker-compose.yml for port mappings"
fi

echo ""
echo "📝 View logs: docker compose logs -f"
echo "🛑 Stop services: docker compose down"
```

## Post-Deployment Actions

### Automatic Context Updates
- Update `.claude/memory/project_context.md` with deployment status
- Log deployment timestamp and configuration
- Add any deployment issues to known issues tracker

### Validation Checks
1. **Service Health**: All containers running and healthy
2. **API Endpoints**: REST APIs responding correctly  
3. **Database Connectivity**: All database connections established
4. **Network Connectivity**: Inter-service communication working
5. **Authentication**: JWT tokens and API keys functional

### Rollback Procedure
If deployment fails:
1. Stop new containers: `docker compose down`
2. Restore previous version if available
3. Check logs: `docker compose logs`
4. Update project status in memory context
5. Alert about deployment failure

## Environment-Specific Variations

### Development Environment
- Enable debug logging
- Expose additional ports for development tools
- Mount source code as volumes for hot reload
- Use development database configurations

### Production Environment  
- Enable health checks and restart policies
- Configure resource limits
- Use production database URLs
- Enable monitoring and alerting
- Set up backup procedures

## Integration with Network Projects

### Fortinet Projects
- Validate FortiGate API connectivity
- Check SNMP community string configuration
- Verify certificate handling

### AI-Enhanced Projects
- Ensure vector database connectivity (Milvus)
- Validate LLM provider APIs (OpenAI, Ollama)
- Check AutoGen agent configuration

### Multi-Service Projects
- Coordinate database initialization order
- Verify service discovery configuration  
- Check load balancer and reverse proxy setup