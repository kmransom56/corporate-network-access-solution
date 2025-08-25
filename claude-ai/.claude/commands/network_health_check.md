# Network Health Check Command

## Purpose  
Comprehensive health assessment of network infrastructure projects and services

## Usage
`/network_health_check [scope] [output_format]`

## Arguments
- `$SCOPE` - Check scope (full, services, fortinet, ai_systems) [default: full]
- `$OUTPUT_FORMAT` - Output format (summary, detailed, json) [default: summary]

## Command Template

```bash
# Network Infrastructure Health Check
echo "🏥 Network Infrastructure Health Check ($SCOPE scope, $OUTPUT_FORMAT format)..."

# 1. Initialize health check results
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
HEALTH_SCORE=100
CRITICAL_ISSUES=0
WARNING_ISSUES=0
INFO_ITEMS=0

echo "🔍 Starting health assessment at $TIMESTAMP"
echo ""

# 2. Docker Infrastructure Health
echo "🐳 Docker Infrastructure Status:"

# Check Docker daemon
if ! docker info > /dev/null 2>&1; then
    echo "   ❌ CRITICAL: Docker daemon not running"
    HEALTH_SCORE=$((HEALTH_SCORE - 30))
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
else
    echo "   ✅ Docker daemon: Running"
    
    # Check Docker resources
    docker_info=$(docker info --format "{{.MemTotal}} {{.NCPU}}")
    echo "   📊 System Resources: $docker_info"
    
    # Check running containers
    running_containers=$(docker ps -q | wc -l)
    total_containers=$(docker ps -aq | wc -l)
    echo "   📦 Containers: $running_containers running, $total_containers total"
    
    if [ $running_containers -eq 0 ]; then
        echo "   ⚠️  WARNING: No containers currently running"
        HEALTH_SCORE=$((HEALTH_SCORE - 10))
        WARNING_ISSUES=$((WARNING_ISSUES + 1))
    fi
fi

echo ""

# 3. Network Project Health Assessment
if [ "$SCOPE" = "full" ] || [ "$SCOPE" = "services" ]; then
    echo "🌐 Network Project Services Health:"
    
    # Check key network management projects
    for project in "fortinet-manager" "ai-network-management-system" "fortigate-dashboard" "network-ai-troubleshooter" "mcp_server"; do
        if [ -d "$project" ]; then
            echo "   🔧 $project:"
            
            # Check if docker-compose exists
            if [ -f "$project/docker-compose.yml" ]; then
                cd "$project"
                
                # Check service status
                if docker compose ps -q > /dev/null 2>&1; then
                    running_services=$(docker compose ps --services --filter status=running | wc -l)
                    total_services=$(docker compose ps --services | wc -l)
                    
                    if [ $running_services -eq $total_services ] && [ $total_services -gt 0 ]; then
                        echo "      ✅ Services: $running_services/$total_services running"
                        INFO_ITEMS=$((INFO_ITEMS + 1))
                    elif [ $running_services -gt 0 ]; then
                        echo "      ⚠️  Services: $running_services/$total_services running (partial)"
                        HEALTH_SCORE=$((HEALTH_SCORE - 5))
                        WARNING_ISSUES=$((WARNING_ISSUES + 1))
                    else
                        echo "      ❌ Services: 0/$total_services running"
                        HEALTH_SCORE=$((HEALTH_SCORE - 15))
                        CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
                    fi
                    
                    # Check service health (if health checks defined)
                    unhealthy_services=$(docker compose ps --format json | jq -r 'select(.Health == "unhealthy") | .Service' 2>/dev/null | wc -l)
                    if [ $unhealthy_services -gt 0 ]; then
                        echo "      ⚠️  Unhealthy services detected: $unhealthy_services"
                        HEALTH_SCORE=$((HEALTH_SCORE - 10))
                        WARNING_ISSUES=$((WARNING_ISSUES + 1))
                    fi
                else
                    echo "      ❌ Docker Compose not active"
                    HEALTH_SCORE=$((HEALTH_SCORE - 10))
                    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
                fi
                
                cd ..
            else
                echo "      ⚠️  No docker-compose.yml found"
                WARNING_ISSUES=$((WARNING_ISSUES + 1))
            fi
            
            # Check for recent activity
            if [ -f "$project/package.json" ] || [ -f "$project/requirements.txt" ]; then
                recent_changes=$(find "$project" -name "*.js" -o -name "*.py" -o -name "*.ts" -o -name "*.tsx" -newerct "7 days ago" 2>/dev/null | wc -l)
                if [ $recent_changes -gt 0 ]; then
                    echo "      📈 Recent activity: $recent_changes files modified (last 7 days)"
                    INFO_ITEMS=$((INFO_ITEMS + 1))
                fi
            fi
        else
            echo "   ⚠️  $project: Directory not found"
            WARNING_ISSUES=$((WARNING_ISSUES + 1))
        fi
        echo ""
    done
fi

# 4. Fortinet-Specific Health Checks
if [ "$SCOPE" = "full" ] || [ "$SCOPE" = "fortinet" ]; then
    echo "🛡️  Fortinet Integration Health:"
    
    # Check MCP server
    if [ -d "mcp_server/fortinet" ]; then
        echo "   🔌 MCP Fortinet Server:"
        
        # Check for API configuration
        if [ -f "mcp_server/fortinet/.env" ]; then
            echo "      ✅ Configuration file present"
        else
            echo "      ⚠️  No .env configuration found"
            WARNING_ISSUES=$((WARNING_ISSUES + 1))
        fi
        
        # Check for recent API activity logs
        if [ -f "mcp_server/fortinet/fortinet_api.log" ]; then
            recent_api_calls=$(find "mcp_server/fortinet" -name "*.log" -newerct "24 hours ago" 2>/dev/null | wc -l)
            if [ $recent_api_calls -gt 0 ]; then
                echo "      📊 Recent API activity detected"
                INFO_ITEMS=$((INFO_ITEMS + 1))
            fi
        fi
    else
        echo "   ❌ MCP Fortinet Server: Not found"
        CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
        HEALTH_SCORE=$((HEALTH_SCORE - 15))
    fi
    
    # Check fortinet-manager health
    if [ -d "fortinet-manager" ]; then
        echo "   🎛️  Fortinet Manager:"
        
        cd "fortinet-manager"
        if [ -f "docker-compose.yml" ] && docker compose ps -q > /dev/null 2>&1; then
            # Check specific services
            api_status=$(docker compose ps api --format json 2>/dev/null | jq -r '.Status' 2>/dev/null)
            frontend_status=$(docker compose ps frontend --format json 2>/dev/null | jq -r '.Status' 2>/dev/null)
            
            if [[ $api_status == *"Up"* ]]; then
                echo "      ✅ API Service: Running"
            else
                echo "      ❌ API Service: $api_status"
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            fi
            
            if [[ $frontend_status == *"Up"* ]]; then
                echo "      ✅ Frontend: Running"
            else
                echo "      ❌ Frontend: $frontend_status"
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            fi
        fi
        cd ..
    fi
    echo ""
fi

# 5. AI Systems Health Check
if [ "$SCOPE" = "full" ] || [ "$SCOPE" = "ai_systems" ]; then
    echo "🤖 AI Systems Health:"
    
    # Check AI network management system
    if [ -d "ai-network-management-system" ]; then
        echo "   🧠 AI Network Management:"
        
        cd "ai-network-management-system"
        if [ -f "docker-compose.yml" ] && docker compose ps -q > /dev/null 2>&1; then
            # Check Neo4j (critical for AI operations)
            neo4j_status=$(docker compose ps neo4j --format json 2>/dev/null | jq -r '.Status' 2>/dev/null)
            if [[ $neo4j_status == *"Up"* ]]; then
                echo "      ✅ Neo4j Database: Running"
                
                # Test Neo4j connectivity
                if docker compose exec -T neo4j cypher-shell "RETURN 'Health Check' as status" > /dev/null 2>&1; then
                    echo "      ✅ Neo4j Connectivity: OK"
                else
                    echo "      ⚠️  Neo4j Connectivity: Issues detected"
                    WARNING_ISSUES=$((WARNING_ISSUES + 1))
                fi
            else
                echo "      ❌ Neo4j Database: $neo4j_status"
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
                HEALTH_SCORE=$((HEALTH_SCORE - 20))
            fi
            
            # Check Redis (important for caching)
            redis_status=$(docker compose ps redis --format json 2>/dev/null | jq -r '.Status' 2>/dev/null)
            if [[ $redis_status == *"Up"* ]]; then
                echo "      ✅ Redis Cache: Running"
            else
                echo "      ⚠️  Redis Cache: $redis_status"
                WARNING_ISSUES=$((WARNING_ISSUES + 1))
            fi
        fi
        cd ..
    fi
    
    # Check network troubleshooter
    if [ -d "network-ai-troubleshooter" ]; then
        echo "   🔧 AI Troubleshooter:"
        
        cd "network-ai-troubleshooter"
        if [ -f "docker-compose.yml" ] && docker compose ps -q > /dev/null 2>&1; then
            app_status=$(docker compose ps app --format json 2>/dev/null | jq -r '.Status' 2>/dev/null)
            if [[ $app_status == *"Up"* ]]; then
                echo "      ✅ Troubleshooter App: Running"
            else
                echo "      ❌ Troubleshooter App: $app_status"
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            fi
        fi
        cd ..
    fi
    echo ""
fi

# 6. Database Health Assessment
echo "🗄️  Database Infrastructure:"

# Check for common databases across projects
for db_type in "neo4j" "mongodb" "redis" "postgres"; do
    containers=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep -i $db_type)
    if [ ! -z "$containers" ]; then
        echo "   ✅ $db_type containers found:"
        echo "$containers" | sed 's/^/      /'
        INFO_ITEMS=$((INFO_ITEMS + 1))
    fi
done

echo ""

# 7. Network Connectivity Health
echo "🌐 Network Connectivity:"

# Check basic network connectivity
if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "   ✅ Internet connectivity: OK"
else
    echo "   ❌ Internet connectivity: FAILED"
    CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
    HEALTH_SCORE=$((HEALTH_SCORE - 25))
fi

# Check local FortiGate (if configured)
if ping -c 1 192.168.0.254 > /dev/null 2>&1; then
    echo "   ✅ FortiGate gateway: Reachable"
    INFO_ITEMS=$((INFO_ITEMS + 1))
else
    echo "   ⚠️  FortiGate gateway: Not reachable (may be expected)"
fi

echo ""

# 8. Calculate and Display Final Health Score
echo "📊 Health Assessment Summary:"
echo "   🏥 Overall Health Score: $HEALTH_SCORE/100"

if [ $HEALTH_SCORE -ge 90 ]; then
    health_status="EXCELLENT"
    status_emoji="🟢"
elif [ $HEALTH_SCORE -ge 75 ]; then
    health_status="GOOD"  
    status_emoji="🟡"
elif [ $HEALTH_SCORE -ge 50 ]; then
    health_status="NEEDS ATTENTION"
    status_emoji="🟠"
else
    health_status="CRITICAL"
    status_emoji="🔴"
fi

echo "   $status_emoji System Status: $health_status"
echo "   🚨 Critical Issues: $CRITICAL_ISSUES"
echo "   ⚠️  Warning Issues: $WARNING_ISSUES"  
echo "   ℹ️  Info Items: $INFO_ITEMS"

# 9. Generate Recommendations
echo ""
echo "💡 Health Improvement Recommendations:"

if [ $CRITICAL_ISSUES -gt 0 ]; then
    echo "   🚨 IMMEDIATE ACTION REQUIRED:"
    echo "      - Address $CRITICAL_ISSUES critical issues before proceeding"
    echo "      - Consider running '/analyze_project [failing_project] health' for details"
fi

if [ $WARNING_ISSUES -gt 0 ]; then
    echo "   ⚠️  SCHEDULED MAINTENANCE RECOMMENDED:"
    echo "      - $WARNING_ISSUES warning issues should be addressed"
    echo "      - Schedule maintenance window for non-critical fixes"
fi

if [ $HEALTH_SCORE -ge 90 ]; then
    echo "   ✅ SYSTEM HEALTHY:"
    echo "      - Continue normal operations"
    echo "      - Consider performance optimizations"
fi

# 10. Log health check results
echo ""
echo "📝 Logging health check results to memory..."

# Update memory with health check results
echo "# Health Check: Network Infrastructure" >> .claude/memory/analysis_history.md
echo "Date: $TIMESTAMP" >> .claude/memory/analysis_history.md
echo "Analysis Type: network_health_check" >> .claude/memory/analysis_history.md
echo "Status: Health assessment completed" >> .claude/memory/analysis_history.md
echo "Key Findings:" >> .claude/memory/analysis_history.md
echo "   - Overall Health Score: $HEALTH_SCORE/100" >> .claude/memory/analysis_history.md
echo "   - Critical Issues: $CRITICAL_ISSUES" >> .claude/memory/analysis_history.md
echo "   - Warning Issues: $WARNING_ISSUES" >> .claude/memory/analysis_history.md
echo "   - System Status: $health_status" >> .claude/memory/analysis_history.md
echo "Actions Taken: Comprehensive infrastructure health assessment" >> .claude/memory/analysis_history.md
echo "---" >> .claude/memory/analysis_history.md
echo "" >> .claude/memory/analysis_history.md

echo "✅ Network health check complete!"
echo "📋 Results logged to AI assistant memory for future reference"

# 11. Exit with appropriate code
if [ $CRITICAL_ISSUES -gt 0 ]; then
    exit 1  # Critical issues detected
elif [ $WARNING_ISSUES -gt 0 ]; then
    exit 2  # Warning issues detected  
else
    exit 0  # All healthy
fi
```

## Integration with AI Assistant

### Automated Scheduling
- **Daily Health Check**: Basic service status verification
- **Weekly Deep Check**: Comprehensive health assessment with performance analysis
- **Post-Deployment**: Immediate health verification after service changes
- **Alert Triggered**: Health check when system issues are suspected

### Health Score Thresholds
- **90-100**: Excellent - System operating optimally
- **75-89**: Good - Minor optimization opportunities
- **50-74**: Needs Attention - Scheduled maintenance required
- **Below 50**: Critical - Immediate intervention required

### Memory Integration
Health check results are automatically stored in the AI assistant's memory system for:
- **Trend Analysis**: Track infrastructure health over time
- **Problem Correlation**: Identify patterns in recurring issues
- **Performance Baseline**: Establish normal operating parameters
- **Predictive Maintenance**: Anticipate issues before they become critical

This health check system provides the AI assistant with real-time awareness of your network infrastructure status, enabling proactive maintenance and intelligent operational recommendations.