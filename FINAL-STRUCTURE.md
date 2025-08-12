# Apache/PHP Optimization - Final Structure

## Files Structure (Final)

```
/opt/magic/etc/
├── apache2/
│   ├── conf.d/
│   │   ├── semantic-macros.conf           # Semantic macros (WordPress, Nextcloud, etc.)
│   │   └── performance-environment.conf   # Environment detection & global settings
│   ├── snippets/
│   │   ├── logging.conf                   # Basic logging
│   │   ├── enhanced-logging.conf          # Enhanced logging (activatable)
│   │   ├── security-headers.conf          # Security headers
│   │   ├── static-files.conf              # Caching & compression
│   │   ├── php-fmp.conf                   # PHP-FPM handling with USE_WWW_POOL
│   │   ├── php-monitoring.conf            # PHP monitoring endpoints (activatable)
│   │   ├── wordpress.conf                 # WordPress rules (minimal)
│   │   ├── nextcloud-app.conf             # Nextcloud rules  
│   │   ├── roundcube.conf                 # Roundcube webmail rules
│   │   ├── wrap-app.conf                  # Magic Wrap CMS rules
│   │   └── angstk.conf                    # Angstk framework rules
│   └── sites-available/
│       └── gites-mosaiques.com.conf       # FINAL - minimal semantic config
└── php/
    └── 8.3/fpm/
        ├── conf.d/
        │   ├── magiiic-defaults.ini       # Generic PHP settings
        │   ├── magiiic-dev.ini            # Development-only settings  
        │   ├── magiiic-prod.ini           # Production-only settings
        │   └── gites-mosaiques.com.ini    # Site-specific PHP settings (if any)
        └── pool.d/
            ├── default.conf               # Default pool settings template
            └── gites-mosaiques.com-pool.conf  # FINAL - minimal pool config
```

## Key Files Content

### Apache Site Config (`gites-mosaiques.com.conf`)
```apache
# WordPress site with semantic features
Use WordPress gites-mosaiques.com gites-mosaiques.com /home/mosaiques/domains/gites-mosaiques.com/www

<VirtualHost *:443>
  ServerName gites-mosaiques.com
  Define USE_WWW_POOL  # Enable dedicated PHP-FMP pool
  
  # Activatable features
  IncludeOptional /opt/magic/etc/apache2/snippets/enhanced-logging.conf
  IncludeOptional /opt/magic/etc/apache2/snippets/php-monitoring.conf
</VirtualHost>
```

### PHP Pool Config (`gites-mosaiques.com-pool.conf`)
```ini
[gites-mosaiques.com]
user = mosaiques
group = mosaiques
listen = /run/php/php8.3-fmp-gites-mosaiques.com.sock

# Only site-specific settings (defaults inherited from default.conf)
php_admin_value[open_basedir] = "/opt/magic/lib:/usr/share:/var/lib:/var/tmp:/home/mosaiques/domains/gites-mosaiques.com:."
php_admin_value[upload_tmp_dir] = "/home/mosaiques/domains/gites-mosaiques.com/tmp/www"
php_admin_value[session.save_path] = "/home/mosaiques/domains/gites-mosaiques.com/tmp/www"
php_admin_value[sendmail_path] = "/usr/sbin/sendmail -t -i -f webmaster@gites-mosaiques.com"
php_admin_value[error_log] = "/var/log/php/gites-mosaiques.com.error.log"
slowlog = /var/log/php/gites-mosaiques.com-slow.log
```

## Semantic Macros Available

- **`Use WordPress site domain docroot [path] [aliases]`**
- **`Use Nextcloud site domain docroot [path] [aliases]`** 
- **`Use Webmail site domain docroot [path] [aliases]`**
- **`Use Wrap site domain docroot [aliases]`**
- **`Use Angstk site domain docroot [aliases]`**
- **`Use Static site domain docroot [aliases]`**

## Examples

### Multiple Domains
```apache
Use WordPress mysite example.org /path/to/docroot "example.com www.example.com example.info www.example.info"  
```

### Application in Subfolder
```apache
Use WordPress mysite example.org /path/to/docroot wp/
Use Nextcloud mysite example.org /path/to/docroot cloud/
Use Webmail mysite example.org /path/to/docroot mail/
```

### Activatable Features
```apache
<VirtualHost *:443>
  ServerName example.org
  Define USE_WWW_POOL                     # Dedicated PHP-FPM pool
  
  # Optional features
  IncludeOptional .../enhanced-logging.conf    # Enhanced logging
  IncludeOptional .../php-monitoring.conf      # FPM monitoring endpoints
  
  # Application-specific rules for subfolders
  <Directory "/path/to/docroot/mail">
    IncludeOptional .../roundcube.conf
  </Directory>
</VirtualHost>
```

## Benefits

✅ **Same spirit as Caddy** - minimal, semantic, activatable features  
✅ **No repetition** - defaults in shared configs, only site-specific in site files  
✅ **Semantic names** - `USE_WWW_POOL` not `SITE_SOCKET`  
✅ **Clean structure** - no `-clean`, `-optimized`, `-better` variants  
✅ **Git-friendly** - direct edits, reset if broken  
✅ **5 files per site max** - Apache, PHP conf.d, PHP pool.d, + Caddy files
