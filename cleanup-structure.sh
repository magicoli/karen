#!/bin/bash
# Clean up the PHP/Apache optimization structure
# Remove generic settings from site-specific configs

echo "🧹 Cleaning up optimization structure..."

# Fix PHP-FPM pool config - remove ALL generic settings
cat > /opt/magic/etc/php/8.3/fmp/pool.d/gites-mosaiques.com-pool.conf << 'EOF'
[gites-mosaiques.com]
; Site-specific PHP-FPM pool configuration
; Only site-specific settings here - generic ones are in conf.d files

; Process identity (site-specific)
user = mosaiques
group = mosaiques

; Socket configuration (site-specific)
listen = /run/php/php8.3-fmp-gites-mosaiques.com.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; Site-specific security settings (these MUST be in pool config)
php_admin_value[open_basedir] = "/opt/magic/lib:/usr/share:/var/lib:/var/tmp:/home/mosaiques/domains/gites-mosaiques.com:."
php_admin_value[upload_tmp_dir] = "/home/mosaiques/domains/gites-mosaiques.com/tmp/www"
php_admin_value[session.save_path] = "/home/mosaiques/domains/gites-mosaiques.com/tmp/www"
php_admin_value[sendmail_path] = "/usr/sbin/sendmail -t -i -f webmaster@gites-mosaiques.com"

; Site-specific logging
php_admin_value[error_log] = "/var/log/php/gites-mosaiques.com.error.log"
slowlog = /var/log/php/gites-mosaiques.com-slow.log
EOF

# Clean Apache site config - ultra minimal like Caddy
cat > /opt/magic/etc/apache2/sites-available/gites-mosaiques.com.conf << 'EOF'
# gites-mosaiques.com - Clean semantic Apache configuration
# Same spirit as Caddy: minimal, semantic, activatable features

# WordPress site with default aliases (domain, www.domain, dev.domain)
Use WordPress gites-mosaiques.com gites-mosaiques.com /home/mosaiques/domains/gites-mosaiques.com/www

# Enable site-specific features
<VirtualHost *:443>
  ServerName gites-mosaiques.com
  
  # Use dedicated PHP-FPM pool (semantic)
  Define USE_SITE_POOL
  
  # Site-specific customizations go here if needed
</VirtualHost>
EOF

echo "✅ Structure cleaned!"
echo
echo "📋 Summary:"
echo "  • Apache config: Uses semantic WordPress macro"
echo "  • PHP pool: Only site-specific settings (user, paths, logging)"
echo "  • Generic settings: Moved to shared conf.d files"
echo
echo "🔧 To use different aliases:"
echo "  Use WordPress mysite example.org /path/to/docroot \"example.com www.example.com example.info www.example.info\""
echo
echo "🔧 To use WordPress in subfolder:"
echo "  Use WordPress mysite example.org /path/to/docroot wp/"
echo
echo "🔧 Available semantic macros:"
echo "  • WordPress - WordPress sites"
echo "  • Nextcloud - Nextcloud/Owncloud"
echo "  • Webmail - Roundcube webmail"
echo "  • Wrap - Magic Wrap CMS"
echo "  • Angstk - Angstk framework"
echo "  • Static - Static files only"
