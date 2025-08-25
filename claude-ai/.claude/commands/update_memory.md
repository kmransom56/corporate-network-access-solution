# Update Memory Command

## Purpose
Automated context management and memory updates for the AI assistant

## Usage
`/update_memory [context_type] [project_name]`

## Arguments
- `$CONTEXT_TYPE` - Type of memory update (project, priority, analysis, deployment) [default: project]  
- `$PROJECT_NAME` - Specific project to update context for [optional]

## Command Template

```bash
# AI Assistant Memory Update System
echo "🧠 Updating AI Assistant Memory ($CONTEXT_TYPE context)..."

# 1. Create timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE_ONLY=$(date '+%Y-%m-%d')

# 2. Memory update based on context type
case "$CONTEXT_TYPE" in
    "project"|"")
        echo "📊 Updating project context..."
        
        # Check for recent changes in main projects
        echo "## Project Status Update - $TIMESTAMP" >> .claude/memory/project_context.md
        echo "" >> .claude/memory/project_context.md
        
        # Scan for recent modifications in key directories
        for project in "fortinet-manager" "ai-network-management-system" "fortigate-dashboard" "network-ai-troubleshooter" "port-scanner-material-ui" "mcp_server"; do
            if [ -d "$project" ]; then
                last_modified=$(find "$project" -type f -name "*.js" -o -name "*.py" -o -name "*.ts" -o -name "*.tsx" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" | head -20 | xargs stat -c %Y 2>/dev/null | sort -n | tail -1)
                if [ ! -z "$last_modified" ]; then
                    readable_date=$(date -d "@$last_modified" '+%Y-%m-%d %H:%M')
                    echo "### $project - Last Modified: $readable_date" >> .claude/memory/project_context.md
                    
                    # Check for Docker services status
                    if [ -f "$project/docker-compose.yml" ]; then
                        cd "$project"
                        if docker compose ps -q > /dev/null 2>&1; then
                            running_services=$(docker compose ps --services --filter status=running | wc -l)
                            total_services=$(docker compose ps --services | wc -l)
                            echo "   Docker Services: $running_services/$total_services running" >> ../.claude/memory/project_context.md
                        else
                            echo "   Docker Services: Not running" >> ../.claude/memory/project_context.md
                        fi
                        cd ..
                    fi
                    
                    # Check for recent commits
                    if [ -d "$project/.git" ]; then
                        cd "$project"
                        recent_commit=$(git log -1 --pretty=format:"%h - %s (%ar)" 2>/dev/null)
                        if [ ! -z "$recent_commit" ]; then
                            echo "   Recent Commit: $recent_commit" >> ../.claude/memory/project_context.md
                        fi
                        cd ..
                    fi
                fi
                echo "" >> .claude/memory/project_context.md
            fi
        done
        ;;
        
    "priority")
        echo "🎯 Updating task priorities..."
        
        # Add priority update timestamp
        echo "" >> .claude/tasks/current_priorities.md
        echo "## Priority Review - $TIMESTAMP" >> .claude/tasks/current_priorities.md
        echo "*Priorities reviewed and current as of this timestamp*" >> .claude/tasks/current_priorities.md
        echo "" >> .claude/tasks/current_priorities.md
        
        # Check for overdue tasks (simple date comparison)
        echo "### Overdue Task Check" >> .claude/tasks/current_priorities.md
        grep -n "Deadline:" .claude/tasks/current_priorities.md | while read line; do
            echo "   Reviewing: $line" >> .claude/tasks/current_priorities.md
        done
        echo "" >> .claude/tasks/current_priorities.md
        ;;
        
    "analysis")
        echo "🔍 Logging analysis activity..."
        
        # Add analysis entry
        echo "# Project Analysis: Auto-Update" >> .claude/memory/analysis_history.md
        echo "Date: $TIMESTAMP" >> .claude/memory/analysis_history.md
        echo "Analysis Type: automated_context_update" >> .claude/memory/analysis_history.md
        echo "Status: Memory system updated successfully" >> .claude/memory/analysis_history.md
        echo "Key Findings:" >> .claude/memory/analysis_history.md
        
        # Count active docker services across all projects
        active_services=0
        for project in "fortinet-manager" "ai-network-management-system" "fortigate-dashboard" "network-ai-troubleshooter"; do
            if [ -d "$project" ] && [ -f "$project/docker-compose.yml" ]; then
                cd "$project"
                if docker compose ps -q > /dev/null 2>&1; then
                    services=$(docker compose ps --services --filter status=running | wc -l)
                    active_services=$((active_services + services))
                fi
                cd ..
            fi
        done
        echo "   - Total active Docker services across projects: $active_services" >> .claude/memory/analysis_history.md
        
        # Count recent file changes
        recent_changes=$(find . -name "*.js" -o -name "*.py" -o -name "*.ts" -o -name "*.tsx" -newerct "24 hours ago" 2>/dev/null | wc -l)
        echo "   - Files modified in last 24 hours: $recent_changes" >> .claude/memory/analysis_history.md
        
        echo "Actions Taken: Automated memory system update" >> .claude/memory/analysis_history.md
        echo "---" >> .claude/memory/analysis_history.md
        echo "" >> .claude/memory/analysis_history.md
        ;;
        
    "deployment")
        echo "🚀 Updating deployment context..."
        
        if [ ! -z "$PROJECT_NAME" ]; then
            # Log deployment activity for specific project
            echo "## Deployment Activity - $TIMESTAMP" >> .claude/memory/project_context.md
            echo "### $PROJECT_NAME Deployment Status" >> .claude/memory/project_context.md
            
            if [ -d "$PROJECT_NAME" ]; then
                cd "$PROJECT_NAME"
                
                # Check Docker service status
                if [ -f "docker-compose.yml" ]; then
                    if docker compose ps -q > /dev/null 2>&1; then
                        echo "   Status: Services running" >> ../.claude/memory/project_context.md
                        docker compose ps --format "   - {{.Service}}: {{.Status}}" >> ../.claude/memory/project_context.md
                    else
                        echo "   Status: Services not running" >> ../.claude/memory/project_context.md
                    fi
                fi
                
                # Check for recent deployment files changes
                deployment_files="docker-compose.yml Dockerfile .env requirements.txt package.json"
                for file in $deployment_files; do
                    if [ -f "$file" ]; then
                        mod_time=$(stat -c %Y "$file" 2>/dev/null)
                        readable_date=$(date -d "@$mod_time" '+%Y-%m-%d %H:%M')
                        echo "   $file modified: $readable_date" >> ../.claude/memory/project_context.md
                    fi
                done
                
                cd ..
            fi
            echo "" >> .claude/memory/project_context.md
        fi
        ;;
esac

# 3. Update global memory stats
echo "📈 Updating global memory statistics..."

# Count total projects
total_projects=$(find . -maxdepth 1 -type d -name "*fortinet*" -o -name "*ai-*" -o -name "*network*" | wc -l)

# Count active containers
active_containers=$(docker ps -q | wc -l)

# Update project context summary
echo "## Global System Status - $TIMESTAMP" >> .claude/memory/project_context.md
echo "- Network projects tracked: $total_projects" >> .claude/memory/project_context.md
echo "- Active Docker containers: $active_containers" >> .claude/memory/project_context.md
echo "- Memory system last updated: $TIMESTAMP" >> .claude/memory/project_context.md
echo "" >> .claude/memory/project_context.md

# 4. Cleanup old memory entries (keep last 50 entries to prevent file bloat)
for memory_file in ".claude/memory/project_context.md" ".claude/memory/analysis_history.md"; do
    if [ -f "$memory_file" ]; then
        line_count=$(wc -l < "$memory_file")
        if [ $line_count -gt 1000 ]; then
            echo "🧹 Cleaning up $memory_file (reducing from $line_count lines)..."
            tail -500 "$memory_file" > "${memory_file}.tmp"
            mv "${memory_file}.tmp" "$memory_file"
        fi
    fi
done

echo "✅ Memory update complete ($CONTEXT_TYPE)"

# 5. Provide status summary
echo ""
echo "📋 Current AI Assistant Memory Status:"
echo "   Project Context: $(wc -l < .claude/memory/project_context.md) lines"
echo "   Analysis History: $(wc -l < .claude/memory/analysis_history.md) lines"  
echo "   Current Priorities: $(grep -c "###" .claude/tasks/current_priorities.md) active tasks"
echo "   Available Commands: $(ls .claude/commands/*.md | wc -l)"
echo "   Configured Agents: $(ls .claude/agents/*.md | wc -l)"

# 6. Suggest next actions based on findings
echo ""
echo "💡 AI Assistant Recommendations:"

if [ $active_containers -eq 0 ]; then
    echo "   🚨 No Docker containers running - consider starting key services"
fi

if [ $recent_changes -gt 10 ]; then
    echo "   📝 High activity detected ($recent_changes recent changes) - consider running project analysis"
fi

if [ $total_projects -gt 5 ]; then
    echo "   🔍 Multiple active projects - prioritize high-impact items from current_priorities.md"
fi

echo "   📅 Schedule regular memory updates (recommended: daily)"
echo "   🤖 Consider delegating research tasks to specialized agents"
```

## Integration with AI Assistant Workflow

### Automated Triggers
- **Daily**: Run `/update_memory project` to scan for changes
- **After deployments**: Run `/update_memory deployment [project]`
- **Weekly**: Run `/update_memory priority` to review task status  
- **After analysis**: Run `/update_memory analysis` to log findings

### Memory Maintenance
- **Automatic cleanup** when memory files exceed 1000 lines
- **Timestamp tracking** for all memory updates
- **Status summaries** provide quick health overview
- **Actionable recommendations** based on current state

### Context Preservation
The memory system ensures that:
1. **Project state** is continuously tracked and updated
2. **Historical patterns** are preserved for learning
3. **Priority alignment** is maintained across sessions
4. **Deployment status** is accurately reflected
5. **Resource utilization** is monitored for optimization

This automated memory management transforms the AI assistant from a stateless tool into a persistent, learning system that builds institutional knowledge about your network infrastructure projects.