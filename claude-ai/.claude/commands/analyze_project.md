# Analyze Project Command

## Purpose
Comprehensive analysis of network infrastructure project health and status

## Usage
`/analyze_project [project_name] [analysis_type]`

## Arguments
- `$PROJECT_NAME` - Name of project directory (e.g., fortinet-manager, ai-network-management-system)
- `$ANALYSIS_TYPE` - Type of analysis (health, security, performance, dependencies) [default: health]

## Command Template

```bash
# Network Infrastructure Project Analysis
echo "🔍 Analyzing $PROJECT_NAME ($ANALYSIS_TYPE analysis)..."

# 1. Validate project exists
if [ ! -d "$PROJECT_NAME" ]; then
    echo "❌ Error: Project directory '$PROJECT_NAME' not found"
    exit 1
fi

cd "$PROJECT_NAME"

# 2. Basic project information
echo "📊 Project Information:"
echo "   Name: $PROJECT_NAME"
echo "   Location: $(pwd)"
echo "   Last Modified: $(stat -c %y . | cut -d' ' -f1)"

# 3. Technology stack detection
echo ""
echo "🛠️  Technology Stack:"

if [ -f "package.json" ]; then
    echo "   ✅ Node.js project detected"
    node_version=$(node --version 2>/dev/null || echo "not installed")
    echo "      Node.js version: $node_version"
    echo "      Dependencies: $(jq -r '.dependencies | length' package.json 2>/dev/null || echo "unable to parse")"
fi

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    echo "   ✅ Python project detected"
    python_version=$(python3 --version 2>/dev/null || echo "not installed")
    echo "      Python version: $python_version"
    if [ -f "requirements.txt" ]; then
        req_count=$(wc -l < requirements.txt)
        echo "      Requirements: $req_count packages"
    fi
fi

if [ -f "docker-compose.yml" ]; then
    echo "   ✅ Docker Compose project"
    services=$(yq eval '.services | length' docker-compose.yml 2>/dev/null || docker compose config --services 2>/dev/null | wc -l)
    echo "      Services: $services"
fi

# 4. Analysis type specific checks
case "$ANALYSIS_TYPE" in
    "health"|"")
        echo ""
        echo "🏥 Health Analysis:"
        
        # Docker services status
        if [ -f "docker-compose.yml" ]; then
            echo "   Docker Services:"
            if docker compose ps > /dev/null 2>&1; then
                docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
            else
                echo "      ⚠️  Services not running"
            fi
        fi
        
        # File structure validation
        echo "   Required Files:"
        for file in "README.md" ".env.example" "docker-compose.yml"; do
            if [ -f "$file" ]; then
                echo "      ✅ $file"
            else
                echo "      ❌ $file (missing)"
            fi
        done
        
        # Code quality indicators
        if [ -f "package.json" ]; then
            echo "   Node.js Health:"
            if npm list > /dev/null 2>&1; then
                echo "      ✅ Dependencies resolved"
            else
                echo "      ❌ Dependency issues detected"
            fi
        fi
        
        if [ -f "requirements.txt" ]; then
            echo "   Python Health:"
            if pip check > /dev/null 2>&1; then
                echo "      ✅ Python dependencies OK"
            else
                echo "      ⚠️  Dependency conflicts may exist"
            fi
        fi
        ;;
        
    "security")
        echo ""
        echo "🔒 Security Analysis:"
        
        # Check for sensitive files
        echo "   Sensitive File Check:"
        for pattern in "*.key" "*.pem" ".env" "*.p12" "credentials.*"; do
            files=$(find . -name "$pattern" 2>/dev/null)
            if [ ! -z "$files" ]; then
                echo "      ⚠️  Found: $pattern"
            fi
        done
        
        # Docker security
        if [ -f "docker-compose.yml" ]; then
            echo "   Docker Security:"
            if grep -q "privileged.*true" docker-compose.yml; then
                echo "      ⚠️  Privileged containers detected"
            else
                echo "      ✅ No privileged containers"
            fi
            
            if grep -q "network_mode.*host" docker-compose.yml; then
                echo "      ⚠️  Host networking detected"
            else
                echo "      ✅ Network isolation maintained"
            fi
        fi
        
        # Environment variable security
        if [ -f ".env.example" ]; then
            echo "   Environment Variables:"
            sensitive_vars=$(grep -E "(PASSWORD|SECRET|KEY|TOKEN)" .env.example | wc -l)
            echo "      Sensitive variables: $sensitive_vars"
        fi
        ;;
        
    "performance")
        echo ""
        echo "⚡ Performance Analysis:"
        
        # Docker resource usage
        if docker compose ps -q > /dev/null 2>&1; then
            echo "   Resource Usage:"
            containers=$(docker compose ps -q)
            for container in $containers; do
                stats=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" $container)
                echo "      $stats"
            done
        fi
        
        # Code size analysis
        echo "   Code Metrics:"
        total_lines=$(find . -name "*.js" -o -name "*.py" -o -name "*.ts" -o -name "*.tsx" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}')
        echo "      Total code lines: ${total_lines:-0}"
        
        # Build size (if applicable)
        if [ -d "build" ] || [ -d "dist" ]; then
            build_size=$(du -sh build dist 2>/dev/null | awk '{print $1}' | head -1)
            echo "      Build size: ${build_size:-unknown}"
        fi
        ;;
        
    "dependencies")
        echo ""
        echo "📦 Dependency Analysis:"
        
        if [ -f "package.json" ]; then
            echo "   Node.js Dependencies:"
            echo "      Production: $(jq -r '.dependencies | length' package.json)"
            echo "      Development: $(jq -r '.devDependencies | length' package.json 2>/dev/null || echo 0)"
            
            # Check for outdated packages
            if command -v npm > /dev/null; then
                outdated=$(npm outdated --json 2>/dev/null | jq length 2>/dev/null || echo 0)
                echo "      Outdated: $outdated"
            fi
        fi
        
        if [ -f "requirements.txt" ]; then
            echo "   Python Dependencies:"
            req_count=$(wc -l < requirements.txt)
            echo "      Requirements: $req_count"
            
            # Check for security vulnerabilities
            if command -v safety > /dev/null; then
                echo "      Running security check..."
                safety check -r requirements.txt 2>/dev/null || echo "      ⚠️  Security check failed"
            fi
        fi
        ;;
esac

# 5. Recommendations
echo ""
echo "💡 Recommendations:"

# Generic recommendations
if [ ! -f "README.md" ]; then
    echo "   📝 Create comprehensive README.md documentation"
fi

if [ ! -f ".gitignore" ]; then
    echo "   🚫 Add .gitignore file for version control"
fi

# Project-specific recommendations based on project type
if [[ "$PROJECT_NAME" == *"fortinet"* ]]; then
    echo "   🔧 Fortinet Project:"
    echo "      - Validate FortiGate API connectivity"
    echo "      - Review SNMP community configuration"
    echo "      - Check certificate handling"
fi

if [[ "$PROJECT_NAME" == *"ai-"* ]]; then
    echo "   🤖 AI Project:"
    echo "      - Monitor vector database performance"
    echo "      - Validate LLM provider connectivity" 
    echo "      - Review AutoGen agent coordination"
fi

if [ -f "docker-compose.yml" ]; then
    echo "   🐳 Docker Project:"
    echo "      - Implement health checks for all services"
    echo "      - Set resource limits for production"
    echo "      - Configure log rotation"
fi

echo ""
echo "✅ Analysis complete for $PROJECT_NAME"

# 6. Update project memory
echo "# Project Analysis: $PROJECT_NAME" >> ../.claude/memory/analysis_history.md
echo "Date: $(date)" >> ../.claude/memory/analysis_history.md
echo "Analysis Type: $ANALYSIS_TYPE" >> ../.claude/memory/analysis_history.md
echo "Status: Analysis completed successfully" >> ../.claude/memory/analysis_history.md
echo "" >> ../.claude/memory/analysis_history.md
```

## Integration with AI Assistant

### Automated Triggers
- Run health analysis after deployments
- Schedule weekly dependency analysis
- Security analysis before production deployments
- Performance analysis when issues reported

### Context Updates
- Store analysis results in `.claude/memory/analysis_history.md`
- Update project status in main context file
- Flag issues for follow-up in tasks directory

### Actionable Insights
Analysis results should generate:
1. **Immediate Actions** - Critical issues requiring instant attention
2. **Improvement Tasks** - Performance and security enhancements  
3. **Monitoring Alerts** - Ongoing health check configurations
4. **Documentation Updates** - README and configuration improvements