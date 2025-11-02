#!/usr/bin/env bash
set -euo pipefail

README="README.md"
UTC_TIME="$(date -u +"%Y-%m-%d %H:%M:%S UTC")"

echo "🔄 Starting README update at ${UTC_TIME}"

# Ensure README exists
if [ ! -f "$README" ]; then
  echo "❌ Error: $README not found" >&2
  exit 1
fi

# Function to count components
count_components() {
  find src/components -name "*.tsx" -not -path "*/ui/*" 2>/dev/null | wc -l | xargs
}

# Function to count pages
count_pages() {
  find src/pages -name "*.tsx" 2>/dev/null | wc -l | xargs
}

# Function to count UI components
count_ui_components() {
  find src/components/ui -name "*.tsx" 2>/dev/null | wc -l | xargs
}

# Function to get tech versions from package.json
get_tech_versions() {
  if [ -f "package.json" ]; then
    REACT_VERSION=$(grep -oP '"react":\s*"\^?\K[0-9.]+' package.json || echo "18.x")
    VITE_VERSION=$(grep -oP '"vite":\s*"\^?\K[0-9.]+' package.json || echo "latest")
    TS_VERSION=$(grep -oP '"typescript":\s*"\^?\K[0-9.]+' package.json || echo "5.x")
    
    cat << EOF
- **React**: ${REACT_VERSION}
- **TypeScript**: ${TS_VERSION}
- **Vite**: ${VITE_VERSION}
- **Tailwind CSS**: 3.x
- **shadcn/ui**: Component library
- **Radix UI**: Accessible components
EOF
  fi
}

# Function to get recent commits
get_recent_commits() {
  git log -5 --pretty=format:"- %s (%ar)" --no-merges 2>/dev/null || echo "- No recent commits available"
}

# Function to update section between markers
update_section() {
  local start_marker="$1"
  local end_marker="$2"
  local content="$3"
  local temp_file="${README}.tmp"
  
  if grep -q "$start_marker" "$README" && grep -q "$end_marker" "$README"; then
    # Both markers exist - replace content between them
    awk -v start="$start_marker" -v end="$end_marker" -v new="$content" '
      $0 ~ start {
        print
        print new
        skip=1
        next
      }
      $0 ~ end {
        skip=0
      }
      !skip
    ' "$README" > "$temp_file"
    
    if [ -s "$temp_file" ]; then
      mv "$temp_file" "$README"
      echo "✅ Updated section: $start_marker"
    else
      echo "⚠️ Warning: Generated empty file, skipping update for $start_marker"
      rm -f "$temp_file"
    fi
  else
    echo "ℹ️ Markers not found for $start_marker, skipping..."
  fi
}

# Generate content sections
COMPONENTS_COUNT=$(count_components)
PAGES_COUNT=$(count_pages)
UI_COUNT=$(count_ui_components)

STATS_CONTENT="
## 📊 Project Statistics

- **Custom Components**: ${COMPONENTS_COUNT} components
- **UI Components**: ${UI_COUNT} shadcn/ui components
- **Pages**: ${PAGES_COUNT} pages/routes
- **Last Updated**: ${UTC_TIME}
"

TECH_CONTENT="
## 🛠️ Technology Stack

$(get_tech_versions)
"

ACTIVITY_CONTENT="
## 📝 Recent Activity

$(get_recent_commits)

[View full commit history →](../../commits/main)
"

# Update all sections
echo "📝 Updating statistics section..."
update_section "<!-- AUTO-STATS-START -->" "<!-- AUTO-STATS-END -->" "$STATS_CONTENT"

echo "🛠️ Updating technology stack section..."
update_section "<!-- AUTO-TECH-START -->" "<!-- AUTO-TECH-END -->" "$TECH_CONTENT"

echo "📅 Updating recent activity section..."
update_section "<!-- AUTO-ACTIVITY-START -->" "<!-- AUTO-ACTIVITY-END -->" "$ACTIVITY_CONTENT"

echo "✅ README.md update complete at ${UTC_TIME}"
