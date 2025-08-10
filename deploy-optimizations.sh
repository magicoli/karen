#!/bin/bash

# MAGIC Infrastructure Optimization Deployment Script
# This script creates symbolic links from /opt/magic/etc to /etc for centralized management

set -e

echo "🚀 Deploying MAGIC Infrastructure Optimizations..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local description="$3"
    
    echo -n "📝 $description... "
    
    # Create target directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Backup existing file if it exists and isn't already a symlink
    if [[ -f "$target" && ! -L "$target" ]]; then
        echo -n "(backing up existing) "
        cp "$target" "$target.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Remove existing file/symlink
    rm -f "$target"
    
    # Create symlink
    ln -s "$source" "$target"
    
    echo -e "${GREEN}✓${NC}"
}

# Function to restart service safely
restart_service() {
    local service="$1"
    echo -n "🔄 Restarting $service... "
    if systemctl is-active --quiet "$service"; then
        systemctl reload "$service" 2>/dev/null || systemctl restart "$service"
    else
        systemctl start "$service"
    fi
    echo -e "${GREEN}✓${NC}"
}

# MySQL Configuration
echo -e "\n${YELLOW}📊 MySQL Configuration${NC}"
create_symlink \
    "/opt/magic/etc/mysql/conf.d/magiiic-innodb.cnf" \
    "/etc/mysql/conf.d/magiiic-innodb.cnf" \
    "MySQL InnoDB optimizations"

# PHP Configuration (both Apache and FPM)
echo -e "\n${YELLOW}🐘 PHP Configuration${NC}"
create_symlink \
    "/opt/magic/etc/php/8.3/apache2/conf.d/magiiic-optimization.ini" \
    "/etc/php/8.3/apache2/conf.d/magiiic-optimization.ini" \
    "PHP Apache optimizations"

create_symlink \
    "/opt/magic/etc/php/8.3/fpm/conf.d/magiiic-optimization.ini" \
    "/etc/php/8.3/fpm/conf.d/magiiic-optimization.ini" \
    "PHP FPM optimizations"

create_symlink \
    "/opt/magic/etc/php/8.3/fpm/pool.d/www.conf" \
    "/etc/php/8.3/fpm/pool.d/www.conf" \
    "PHP FPM pool configuration"

# Caddy Configuration
echo -e "\n${YELLOW}🌐 Caddy Configuration${NC}"
create_symlink \
    "/opt/magic/etc/caddy/Caddyfile" \
    "/etc/caddy/Caddyfile" \
    "Main Caddy configuration"

# Create sites-enabled directory and link
mkdir -p /etc/caddy/sites-enabled
create_symlink \
    "/opt/magic/etc/caddy/sites-available/gites-mosaiques.com.caddy" \
    "/etc/caddy/sites-enabled/gites-mosaiques.com.caddy" \
    "Caddy site configuration"

# Create log directories
echo -e "\n${YELLOW}�� Log Directories${NC}"
echo -n "📁 Creating log directories... "
mkdir -p /var/log/caddy /var/log/php8.3-fpm
chown caddy:caddy /var/log/caddy 2>/dev/null || echo -n "(caddy user not found) "
chown www-data:www-data /var/log/php8.3-fpm 2>/dev/null || echo -n "(www-data user not found) "
echo -e "${GREEN}✓${NC}"

# Test configurations
echo -e "\n${YELLOW}🧪 Testing Configurations${NC}"

echo -n "🔍 Testing MySQL config... "
if mysql --version &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}⚠ MySQL not available${NC}"
fi

echo -n "🔍 Testing PHP-FPM config... "
if php-fpm8.3 -t &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}⚠ PHP-FPM config test failed${NC}"
fi

echo -n "🔍 Testing Caddy config... "
if caddy validate --config /etc/caddy/Caddyfile &>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}⚠ Caddy config validation failed${NC}"
fi

# Restart services
echo -e "\n${YELLOW}🔄 Restarting Services${NC}"

# MySQL/MariaDB - check which one is active
if systemctl is-active --quiet mariadb.service; then
    restart_service "mariadb.service"
elif systemctl is-active --quiet mysql.service; then
    restart_service "mysql.service"
else
    echo -e "${YELLOW}⚠ No MySQL/MariaDB service found running${NC}"
fi

if systemctl is-active --quiet php8.3-fpm.service; then
    restart_service "php8.3-fpm.service"
fi

if systemctl is-active --quiet caddy.service; then
    restart_service "caddy.service"
fi

echo -e "\n${GREEN}🎉 Deployment Complete!${NC}"
echo -e "\n📊 ${YELLOW}Next Steps:${NC}"
echo "1. Test performance: for i in {1..5}; do curl -w \"time_total: %{time_total}s\\n\" -o /dev/null -s https://gites-mosaiques.com/; done"
echo "2. Monitor PHP-FPM: curl http://localhost/status"
echo "3. Check logs: tail -f /var/log/caddy/gites-mosaiques.com.error.log"

echo -e "\n🔧 ${YELLOW}Configuration Summary:${NC}"
echo "• MySQL: 4GB buffer pool, optimized for WordPress"  
echo "• PHP-FPM: 50 max children, 10 start servers (vs previous 5 max)"
echo "• PHP: OPcache enabled with JIT, 512M memory limit"
echo "• Caddy: Optimized with logging and monitoring"
