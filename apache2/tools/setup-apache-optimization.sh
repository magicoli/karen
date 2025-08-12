#!/bin/bash
# Simple setup script for Apache optimization
# Sets up the proper symlinks based on environment

set -euo pipefail

MAGIC_ETC="/opt/magic/etc"
APACHE_ETC="/etc/apache2"
PHP_ETC="/etc/php/8.3/fmp"

# Function to detect environment
detect_environment() {
    if [[ -d "/etc/letsencrypt/live" ]] && [[ "$(ls -A /etc/letsencrypt/live 2>/dev/null)" ]]; then
        echo "production"
    else
        echo "development"
    fi
}

# Set up PHP environment config
setup_php_environment() {
    local env=$(detect_environment)
    
    echo "Setting up PHP for $env environment..."
    
    # Remove existing environment symlinks
    rm -f "$PHP_ETC/conf/magiiic-dev.ini"
    rm -f "$PHP_ETC/conf/magiiic-prod.ini"
    
    # Create appropriate symlink
    if [[ "$env" == "production" ]]; then
        ln -sf "$MAGIC_ETC/php/8.3/fpm/conf.d/magiiic-prod.ini" "$PHP_ETC/conf/magiiic-prod.ini"
        echo "✓ Enabled production PHP settings"
    else
        ln -sf "$MAGIC_ETC/php/8.3/fpm/conf.d/magiiic-dev.ini" "$PHP_ETC/conf/magiiic-dev.ini" 
        echo "✓ Enabled development PHP settings"
    fi
    
    # Ensure defaults are always linked
    ln -sf "$MAGIC_ETC/php/8.3/fpm/conf.d/magiiic-defaults.ini" "$PHP_ETC/conf/magiiic-defaults.ini" 2>/dev/null || true
    echo "✓ PHP defaults configured"
}

# Set up Apache environment
setup_apache_environment() {
    local env=$(detect_environment)
    
    echo "Setting up Apache for $env environment..."
    
    # Update the performance-environment.conf
    local perf_conf="$APACHE_ETC/conf-available/performance-environment.conf"
    if [[ -f "$perf_conf" ]]; then
        if [[ "$env" == "production" ]]; then
            sed -i 's/Define DEV_SERVER/# Define DEV_SERVER/' "$perf_conf"
            sed -i 's/# Define PROD_SERVER/Define PROD_SERVER/' "$perf_conf"
            echo "✓ Set Apache to production mode"
        else
            sed -i 's/# Define DEV_SERVER/Define DEV_SERVER/' "$perf_conf" 
            sed -i 's/Define PROD_SERVER/# Define PROD_SERVER/' "$perf_conf"
            echo "✓ Set Apache to development mode"
        fi
    fi
}

main() {
    echo "🚀 Setting up Apache/PHP optimization..."
    echo "Environment: $(detect_environment)"
    echo
    
    setup_php_environment
    setup_apache_environment
    
    echo
    echo "✅ Setup complete!"
    echo
    echo "📝 To use the new system:"
    echo "  1. Copy your site config to sites/ using the new macro format"
    echo "  2. Copy your PHP pool config to pool.d/ using the minimal format" 
    echo "  3. Enable the site: a2ensite your-site.conf"
    echo "  4. Test and reload: apache2ctl configtest && systemctl reload apache2"
    echo
    echo "🔍 Example site config:"
    echo "  Use VHostWordPress mysite mysite.com /path/to/docroot"
    echo
    echo "🔍 Available snippets:"
    echo "  - wordpress (included in VHostWordPress macro)"
    echo "  - nextcloud-app"
    echo "  - roundcube"
    echo "  - wrap-app"
    echo "  - angstk"
}

main "$@"
