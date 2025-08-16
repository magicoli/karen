#!/bin/bash
#
# Certbot deploy hook for mail server certificates
# This script runs after certbot successfully renews/updates certificates
# and automatically updates Postfix and Dovecot configurations
#
# Place in: /etc/letsencrypt/renewal-hooks/deploy/mail-server.sh
# Make executable: chmod +x /etc/letsencrypt/renewal-hooks/deploy/mail-server.sh

set -euo pipefail

# Configuration
MAIL_DOMAIN="mail.magiiic.com"
POSTFIX_MAIN="/etc/postfix/main.cf"
DOVECOT_CONF="/etc/dovecot/conf.d/magiiic.conf"

# Find the current certificate directory (handles -0001, -0002, etc.)
find_cert_dir() {
    local domain="$1"
    
    # Try exact match first
    if [[ -d "/etc/letsencrypt/live/$domain" ]]; then
        echo "/etc/letsencrypt/live/$domain"
        return
    fi
    
    # Find the highest numbered version
    local latest_dir
    latest_dir=$(find /etc/letsencrypt/live -maxdepth 1 -name "$domain*" -type d | sort -V | tail -1)
    
    if [[ -n "$latest_dir" && -d "$latest_dir" ]]; then
        echo "$latest_dir"
        return
    fi
    
    echo "ERROR: No certificate directory found for $domain" >&2
    exit 1
}

# Update configuration file with new certificate path
update_config() {
    local config_file="$1"
    local cert_dir="$2"
    
    if [[ ! -f "$config_file" ]]; then
        echo "WARNING: Config file not found: $config_file" >&2
        return
    fi
    
    # Create backup
    cp "$config_file" "$config_file.backup.$(date +%Y%m%d-%H%M%S)"
    
    # Update certificate paths (handle both fullchain.pem and cert.pem)
    sed -i "s|smtpd_tls_cert_file = /etc/letsencrypt/live/[^/]*/|smtpd_tls_cert_file = $cert_dir/|g" "$config_file"
    sed -i "s|smtpd_tls_key_file = /etc/letsencrypt/live/[^/]*/|smtpd_tls_key_file = $cert_dir/|g" "$config_file"
    sed -i "s|ssl_cert = </etc/letsencrypt/live/[^/]*/|ssl_cert = <$cert_dir/|g" "$config_file"
    sed -i "s|ssl_key = </etc/letsencrypt/live/[^/]*/|ssl_key = <$cert_dir/|g" "$config_file"
    
    echo "Updated $config_file with certificate path: $cert_dir"
}

# Test configuration
test_configs() {
    echo "Testing configurations..."
    
    # Test Postfix
    if ! postfix check; then
        echo "ERROR: Postfix configuration test failed" >&2
        return 1
    fi
    
    # Test Dovecot
    if ! doveconf -n >/dev/null; then
        echo "ERROR: Dovecot configuration test failed" >&2
        return 1
    fi
    
    echo "Configuration tests passed"
}

# Reload services
reload_services() {
    echo "Reloading mail services..."
    
    # Reload Postfix
    if systemctl is-active --quiet postfix; then
        systemctl reload postfix
        echo "Postfix reloaded"
    fi
    
    # Reload Dovecot
    if systemctl is-active --quiet dovecot; then
        systemctl reload dovecot
        echo "Dovecot reloaded"
    fi
}

# Main execution
main() {
    echo "=== Certbot deploy hook for mail server ==="
    echo "Triggered for domain: ${RENEWED_DOMAINS:-unknown}"
    
    # Check if this renewal affects our mail domain
    if [[ "${RENEWED_DOMAINS:-}" != *"$MAIL_DOMAIN"* ]]; then
        echo "Mail domain $MAIL_DOMAIN not in renewed domains, skipping"
        exit 0
    fi
    
    # Find current certificate directory
    local cert_dir
    cert_dir=$(find_cert_dir "$MAIL_DOMAIN")
    echo "Using certificate directory: $cert_dir"
    
    # Verify certificates exist
    if [[ ! -f "$cert_dir/fullchain.pem" ]] || [[ ! -f "$cert_dir/privkey.pem" ]]; then
        echo "ERROR: Certificate files not found in $cert_dir" >&2
        exit 1
    fi
    
    # Update configurations
    update_config "$POSTFIX_MAIN" "$cert_dir"
    update_config "$DOVECOT_CONF" "$cert_dir"
    
    # Test configurations
    test_configs
    
    # Reload services
    reload_services
    
    echo "=== Mail server certificate update completed successfully ==="
}

# Run main function
main "$@"
