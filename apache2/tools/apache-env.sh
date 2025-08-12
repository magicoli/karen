#!/bin/bash
# Switch between development and production Apache configurations
# Usage: apache-env.sh [dev|prod]

case "$1" in
  dev|development)
    echo "Switching to DEVELOPMENT environment..."
    sudo a2disconf production 2>/dev/null || true
    sudo a2enconf development
    sudo systemctl reload apache2
    echo "✅ Development environment active"
    echo "   - Caching disabled"
    echo "   - /server-status enabled (localhost only)"
    echo "   - Debug headers active"
    ;;
  prod|production)  
    echo "Switching to PRODUCTION environment..."
    sudo a2disconf development 2>/dev/null || true
    sudo a2enconf production
    sudo systemctl reload apache2
    echo "✅ Production environment active"
    echo "   - Security headers enabled"
    echo "   - OCSP stapling enabled"
    echo "   - Debug endpoints disabled"
    ;;
  status)
    if [[ -f /etc/apache2/conf-enabled/development.conf ]]; then
      echo "🛠️  DEVELOPMENT environment active"
      curl -s -I http://localhost/ | grep -E "X-Environment|Cache-Control" || true
    elif [[ -f /etc/apache2/conf-enabled/production.conf ]]; then
      echo "🚀 PRODUCTION environment active"  
      curl -s -I http://localhost/ | grep -E "X-Environment|Strict-Transport" || true
    else
      echo "❌ No environment configured"
    fi
    ;;
  *)
    echo "Usage: $0 {dev|prod|status}"
    echo ""
    echo "Commands:"
    echo "  dev/development  - Switch to development environment"
    echo "  prod/production  - Switch to production environment" 
    echo "  status          - Show current environment"
    exit 1
    ;;
esac
