#!/bin/bash
# Apache Performance Optimization Deployment Script
# This script helps deploy the optimized Apache configuration

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MAGIC_ETC="/opt/magic/etc"
APACHE_ETC="/etc/apache2"
PHP_ETC="/etc/php/8.3/fpm"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

detect_environment() {
    if [[ -f "/etc/letsencrypt/live/miley.magiiic.com/fullchain.pem" ]] || [[ -d "/etc/letsencrypt/live" ]]; then
        echo "PROD_SERVER"
    else
        echo "DEV_SERVER"
    fi
}

enable_required_modules() {
    log_info "Enabling required Apache modules..."
    
    local modules=(
        "macro"
        "headers" 
        "expires"
        "proxy_fcgi"
        "setenvif"
        "rewrite"
        "ssl"
        "deflate"
        "info"
        "status"
    )
    
    # Optional modules (enable if available)
    local optional_modules=(
        "http2"
        "brotli"
    )
    
    for module in "${modules[@]}"; do
        if a2enmod "$module" 2>/dev/null; then
            log_success "Enabled module: $module"
        else
            log_warning "Module $module may already be enabled or not available"
        fi
    done
    
    for module in "${optional_modules[@]}"; do
        if a2enmod "$module" 2>/dev/null; then
            log_success "Enabled optional module: $module"
        else
            log_info "Optional module $module not available or already enabled"
        fi
    done
}

disable_old_modules() {
    log_info "Disabling old/conflicting Apache modules..."
    
    local old_modules=(
        "mpm_prefork"
        "php8.3"  # mod_php
        "mpm_itk"
    )
    
    for module in "${old_modules[@]}"; do
        if a2dismod "$module" 2>/dev/null; then
            log_success "Disabled module: $module"
        else
            log_info "Module $module not enabled or not available"
        fi
    done
    
    # Enable mpm_event for better performance
    if a2enmod mpm_event 2>/dev/null; then
        log_success "Enabled mpm_event for better performance"
    fi
}

deploy_configuration() {
    log_info "Deploying Apache configuration files..."
    
    # Create backup directory
    local backup_dir="/opt/magic/backup/apache-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup existing configuration
    if [[ -d "$APACHE_ETC/sites" ]]; then
        cp -r "$APACHE_ETC/sites" "$backup_dir/"
        log_info "Backed up existing sites to $backup_dir"
    fi
    
    # Deploy snippets
    if [[ -d "$MAGIC_ETC/apache2/snippets" ]]; then
        cp -r "$MAGIC_ETC/apache2/snippets" "$APACHE_ETC/"
        log_success "Deployed Apache snippets"
    fi
    
    # Deploy conf files
    if [[ -d "$MAGIC_ETC/apache2/conf" ]]; then
        for conf_file in "$MAGIC_ETC/apache2/conf"/*.conf; do
            if [[ -f "$conf_file" ]]; then
                cp "$conf_file" "$APACHE_ETC/conf-available/"
                local basename_conf=$(basename "$conf_file")
                a2enconf "${basename_conf%.conf}"
                log_success "Deployed and enabled: $basename_conf"
            fi
        done
    fi
}

deploy_php_configuration() {
    log_info "Deploying PHP-FPM configuration..."
    
    # Create backup
    local backup_dir="/opt/magic/backup/php-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    if [[ -d "$PHP_ETC/pool.d" ]]; then
        cp -r "$PHP_ETC/pool.d" "$backup_dir/"
        log_info "Backed up existing PHP-FPM pools to $backup_dir"
    fi
    
    # Deploy pool configurations
    if [[ -d "$MAGIC_ETC/php/8.3/fpm/pool.d" ]]; then
        for pool_file in "$MAGIC_ETC/php/8.3/fpm/pool.d"/*.conf; do
            if [[ -f "$pool_file" ]]; then
                cp "$pool_file" "$PHP_ETC/pool.d/"
                log_success "Deployed PHP-FPM pool: $(basename "$pool_file")"
            fi
        done
    fi
    
    # Create required directories
    local sites=($(find "$MAGIC_ETC/php/8.3/fpm/pool.d" -name "*.conf" -exec basename {} .conf \;))
    for site in "${sites[@]}"; do
        local site_user=$(grep "^user = " "$PHP_ETC/pool.d/$site.conf" | cut -d' ' -f3)
        local temp_dir="/home/$site_user/domains/$site/tmp/www"
        if [[ ! -d "$temp_dir" ]]; then
            mkdir -p "$temp_dir"
            chown "$site_user:$site_user" "$temp_dir"
            chmod 755 "$temp_dir"
            log_success "Created temp directory for $site: $temp_dir"
        fi
    done
    
    # Create log directory
    mkdir -p /var/log/php
    chown www-data:www-data /var/log/php
    chmod 755 /var/log/php
}

set_environment() {
    local env_type=$(detect_environment)
    log_info "Detected environment: $env_type"
    
    # Set environment in performance-environment.conf
    local perf_conf="$APACHE_ETC/conf-available/performance-environment.conf"
    if [[ -f "$perf_conf" ]]; then
        if [[ "$env_type" == "PROD_SERVER" ]]; then
            sed -i 's/Define DEV_SERVER/# Define DEV_SERVER/' "$perf_conf"
            sed -i 's/# Define PROD_SERVER/Define PROD_SERVER/' "$perf_conf"
            log_success "Set production environment"
        else
            sed -i 's/# Define DEV_SERVER/Define DEV_SERVER/' "$perf_conf"
            sed -i 's/Define PROD_SERVER/# Define PROD_SERVER/' "$perf_conf"
            log_success "Set development environment"
        fi
    fi
    
    # Update PHP-FPM pools based on environment
    if [[ "$env_type" == "PROD_SERVER" ]]; then
        for pool_file in "$PHP_ETC/pool.d"/*.conf; do
            if [[ -f "$pool_file" ]]; then
                # Enable production settings
                sed -i 's/; php_admin_flag\[opcache.enable\] = on/php_admin_flag[opcache.enable] = on/' "$pool_file"
                sed -i 's/php_admin_flag\[opcache.enable\] = off/; php_admin_flag[opcache.enable] = off/' "$pool_file"
                sed -i 's/php_admin_flag\[display_errors\] = on/; php_admin_flag[display_errors] = on/' "$pool_file"
                sed -i 's/; php_admin_flag\[display_errors\] = off/php_admin_flag[display_errors] = off/' "$pool_file"
                log_success "Enabled production settings in $(basename "$pool_file")"
            fi
        done
    fi
}

test_configuration() {
    log_info "Testing Apache configuration..."
    
    if apache2ctl configtest; then
        log_success "Apache configuration test passed"
    else
        log_error "Apache configuration test failed"
        return 1
    fi
    
    log_info "Testing PHP-FPM configuration..."
    if php-fpm8.3 -t; then
        log_success "PHP-FPM configuration test passed"
    else
        log_error "PHP-FPM configuration test failed"
        return 1
    fi
}

restart_services() {
    log_info "Restarting services..."
    
    systemctl reload apache2
    log_success "Reloaded Apache"
    
    systemctl restart php8.3-fpm
    log_success "Restarted PHP-FPM"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy optimized Apache configuration for performance.

OPTIONS:
    -h, --help      Show this help message
    -t, --test      Test configuration only (don't deploy)
    -f, --force     Force deployment without confirmation
    --dev          Force development environment
    --prod         Force production environment

EXAMPLES:
    $0                 # Interactive deployment
    $0 --test          # Test configuration only
    $0 --force --prod  # Force production deployment
EOF
}

main() {
    local test_only=false
    local force=false
    local env_override=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -t|--test)
                test_only=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            --dev)
                env_override="DEV_SERVER"
                shift
                ;;
            --prod)
                env_override="PROD_SERVER"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    check_root
    
    if [[ "$test_only" == true ]]; then
        log_info "Running configuration test only..."
        test_configuration
        exit 0
    fi
    
    if [[ "$force" != true ]]; then
        echo -e "${YELLOW}This will deploy optimized Apache configuration.${NC}"
        echo -e "${YELLOW}Existing configuration will be backed up.${NC}"
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi
    
    log_info "Starting Apache optimization deployment..."
    
    enable_required_modules
    disable_old_modules
    deploy_configuration
    deploy_php_configuration
    
    if [[ -n "$env_override" ]]; then
        log_info "Using environment override: $env_override"
        # Set environment based on override
        local perf_conf="$APACHE_ETC/conf-available/performance-environment.conf"
        if [[ -f "$perf_conf" ]]; then
            if [[ "$env_override" == "PROD_SERVER" ]]; then
                sed -i 's/Define DEV_SERVER/# Define DEV_SERVER/' "$perf_conf"
                sed -i 's/# Define PROD_SERVER/Define PROD_SERVER/' "$perf_conf"
            else
                sed -i 's/# Define DEV_SERVER/Define DEV_SERVER/' "$perf_conf"
                sed -i 's/Define PROD_SERVER/# Define PROD_SERVER/' "$perf_conf"
            fi
        fi
    else
        set_environment
    fi
    
    test_configuration || exit 1
    restart_services
    
    log_success "Apache optimization deployment completed!"
    log_info "You can now convert individual sites to use the new macros:"
    log_info "  Use VHostPHP site_name server_name doc_root"
    log_info "  Use VHostWordPress site_name server_name doc_root"
    log_info "  Use VHostStatic site_name server_name doc_root"
    
    echo -e "\n${GREEN}Next steps:${NC}"
    echo "1. Update individual site configurations to use the new macros"
    echo "2. Test sites in development before deploying to production"
    echo "3. Monitor performance and adjust PHP-FPM pool settings as needed"
}

main "$@"
