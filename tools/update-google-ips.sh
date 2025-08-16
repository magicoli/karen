#!/bin/bash
#
# Update Google IP ranges in Postfix RBL override file
# This script fetches current Google IP ranges and updates the whitelist
#
# Usage: ./update-google-ips.sh [--dry-run] [--backup]
#
# Author: Karen mail server management
# Last updated: 2025-08-16

set -euo pipefail
. $(dirname $(dirname $(realpath $BASH_SOURCE)))/app/helpers/init

# Configuration
RBL_OVERRIDE_FILE="$KAREN_TEMPLATES/postfix/rbl_override"
GOOGLE_API_URL="https://www.gstatic.com/ipranges/goog.json"
DRY_RUN=false
CREATE_BACKUP=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--dry-run] [--backup]"
            echo "  --dry-run    Show what would be changed without modifying files"
            echo "  --backup     Create backup before modifying"
            exit 0
            ;;
        *)
            log 1 "Unknown option: $1"
            ;;
    esac
done

# Check if required tools are available
check_dependencies() {
    local missing_tools=()
    
    for tool in curl jq; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log 1 "Missing required tools: ${missing_tools[*]}"
        log 1 "Please install them with: apt-get install ${missing_tools[*]}"
    fi
}

# Fetch current Google IP ranges
fetch_google_ips() {
    log "Fetching current Google IP ranges from API..."
    
    if ! curl -s "$GOOGLE_API_URL" > "$TMP.json"; then
        log 1 "Failed to fetch Google IP ranges from $GOOGLE_API_URL"
    fi
    
    if ! jq . "$TMP.json" > /dev/null 2>&1; then
        log 1 "Invalid JSON response from Google API"
    fi
    
    log "Successfully fetched Google IP ranges"
}

# Extract mail-relevant IP ranges
extract_mail_ranges() {
    log "Extracting mail-relevant IP ranges..."
    
    # Extract IPv4 ranges (focus on core mail services, not all Google services)
    local ipv4_ranges
    ipv4_ranges=$(jq -r '.prefixes[] | select(.ipv4Prefix) | .ipv4Prefix' "$TMP.json" 2>/dev/null | \
        grep -E "(64\.233\.|66\.102\.|66\.249\.|72\.14\.|74\.125\.|108\.177\.|142\.250\.|172\.217\.|172\.253\.|173\.194\.|209\.85\.|216\.58\.|216\.239\.)" | \
        sort -V)
    
    # Extract IPv6 ranges (main Google blocks)
    local ipv6_ranges
    ipv6_ranges=$(jq -r '.prefixes[] | select(.ipv6Prefix) | .ipv6Prefix' "$TMP.json" 2>/dev/null | \
        grep -E "(2001:4860:|2404:6800:|2607:f8b0:|2800:3f0:|2a00:1450:|2c0f:fb50:)" | \
        sed 's|/.*|/32|' | sort -u)
    
    # Generate new Google section
    {
        echo "# Google mail services (Gmail, Google Workspace)"
        echo "# Updated $(date '+%Y-%m-%d') - Core mail server ranges only"
        echo "/mail-.*\.google\.com$/	OK"
        echo "/.*\.googlemail\.com$/	OK"
        
        if [[ -n "$ipv4_ranges" ]]; then
            echo "$ipv4_ranges" | while read -r range; do
                [[ -n "$range" ]] && echo "$range   permit"
            done
        fi
        
        if [[ -n "$ipv6_ranges" ]]; then
            echo "$ipv6_ranges" | while read -r range; do
                [[ -n "$range" ]] && echo "$range   permit"
            done
        fi
    } > "$TMP.google_section"
    
    log "Extracted $(echo "$ipv4_ranges" | wc -l) IPv4 and $(echo "$ipv6_ranges" | wc -l) IPv6 ranges"
}

# Create backup if requested
create_backup() {
    if [[ "$CREATE_BACKUP" == true ]]; then
        local backup_file="$KAREN_BASE/tmp/rbl_override.backup.$(date '+%Y%m%d-%H%M%S')"
        log "Creating backup: $backup_file"
        
        mkdir -p "$(dirname "$backup_file")"
        cp "$RBL_OVERRIDE_FILE" "$backup_file"
        log "Backup created: $backup_file"
    fi
}

# Update the RBL override file
update_rbl_file() {
    if [[ ! -f "$RBL_OVERRIDE_FILE" ]]; then
        log 1 "RBL override file not found: $RBL_OVERRIDE_FILE"
    fi
    
    # Find start and end markers for Google section
    local start_line end_line
    start_line=$(grep -n "# Google mail services" "$RBL_OVERRIDE_FILE" | head -1 | cut -d: -f1)
    end_line=$(grep -n "# Microsoft/Outlook.com services" "$RBL_OVERRIDE_FILE" | head -1 | cut -d: -f1)
    
    if [[ -z "$start_line" ]] || [[ -z "$end_line" ]]; then
        log 1 "Could not find Google section markers in $RBL_OVERRIDE_FILE"
        log 1 "Expected '# Google mail services' and '# Microsoft/Outlook.com services' comments"
    fi
    
    # Calculate lines to replace (exclude the Microsoft comment line)
    end_line=$((end_line - 1))
    
    if [[ "$DRY_RUN" == true ]]; then
        log "DRY RUN: Would replace lines $start_line-$end_line with:"
        cat "$TMP.google_section"
        return
    fi
    
    # Create updated file
    {
        # Lines before Google section
        sed -n "1,$((start_line - 1))p" "$RBL_OVERRIDE_FILE"
        
        # New Google section
        cat "$TMP.google_section"
        echo ""
        
        # Lines after Google section
        sed -n "$((end_line + 1)),\$p" "$RBL_OVERRIDE_FILE"
    } > "$TMP.updated_file"
    
    # Replace original file
    mv "$TMP.updated_file" "$RBL_OVERRIDE_FILE"
    log "Updated Google IP ranges in $RBL_OVERRIDE_FILE"
}

# Show changes summary
show_summary() {
    local creation_time sync_token total_prefixes
    creation_time=$(jq -r '.creationTime' "$TMP.json")
    sync_token=$(jq -r '.syncToken' "$TMP.json")
    total_prefixes=$(jq '.prefixes | length' "$TMP.json")
    
    log "Google IP ranges summary:"
    log "  API sync token: $sync_token"
    log "  Data created: $creation_time"
    log "  Total IP prefixes: $total_prefixes"
    
    if [[ "$DRY_RUN" == false ]]; then
        log "Remember to run 'postmap /etc/postfix/rbl_override' after deploying this file"
        log "And restart Postfix with 'systemctl reload postfix'"
    fi
}

# Cleanup function for trap
cleanup() {
    rm -f "$TMP.json" "$TMP.google_section" "$TMP.updated_file"
}

# Set trap for cleanup
trap cleanup EXIT

# Main execution
log "Starting Google IP ranges update for Postfix RBL override"

check_dependencies
fetch_google_ips
show_summary
extract_mail_ranges
create_backup
update_rbl_file

if [[ "$DRY_RUN" == false ]]; then
    log "Google IP ranges updated successfully!"
    log "Next steps:"
    log "1. Review the changes in $RBL_OVERRIDE_FILE"
    log "2. Deploy to /etc/postfix/rbl_override"
    log "3. Run: postmap /etc/postfix/rbl_override"
    log "4. Run: systemctl reload postfix"
else
    log "Dry run completed. No files were modified."
fi

end 0 "Google IP update completed"
