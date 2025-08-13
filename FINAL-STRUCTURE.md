# Apache/PHP Optimization - Final Structure

## Files Structure (Final)

```
/opt/magic/etc/
├── apache2/
│   ├── conf/
│   │   ├── semantic-macros.conf           # Semantic macros (WordPress, Nextcloud, etc.)
│   │   └── performance-environment.conf   # Environment detection & global settings
│   ├── snippets/
│   │   ├── logging.conf                   # Basic logging
│   │   ├── enhanced-logging.conf          # Enhanced logging (activatable)
│   │   ├── security-headers.conf          # Security headers
│   │   ├── static-files.conf              # Caching & compression
│   │   ├── php-fpm.conf                   # PHP-FPM handling with USE_WWW_POOL
│   │   ├── php-monitoring.conf            # PHP monitoring endpoints (activatable)
│   │   ├── wordpress.conf                 # WordPress rules (minimal)
│   │   ├── nextcloud-app.conf             # Nextcloud rules  
│   │   ├── roundcube.conf                 # Roundcube webmail rules
│   │   ├── wrap-app.conf                  # Magic Wrap CMS rules
│   │   └── angstk.conf                    # Angstk framework rules
│   └── sites/
│       └── example.com.conf       # FINAL - minimal semantic config
└── php/
    └── 8.3/fpm/
        ├── conf/
        │   ├── magiiic-defaults.ini       # Generic PHP settings
        │   ├── magiiic-dev.ini            # Development-only settings  
        │   ├── magiiic-prod.ini           # Production-only settings
        │   └── example.com.ini    # Site-specific PHP settings (if any)
        └── pool.d/
            ├── default.conf               # Default pool settings template
            └── example.com-pool.conf  # FINAL - minimal pool config
```

## Key Files Content

### Apache Site Config (`example.com.conf`)
```apache
# WordPress site with semantic features
Use WordPress example.com example.com /home/example_user/domains/example.com/www

<VirtualHost *:443>
  ServerName example.com
  Define USE_WWW_POOL  # Enable dedicated PHP-fpm pool
  
  # Activatable features
  IncludeOptional /opt/magic/etc/apache2/snippets/enhanced-logging.conf
  IncludeOptional /opt/magic/etc/apache2/snippets/php-monitoring.conf
</VirtualHost>
```

### PHP Pool Config (`example.com-pool.conf`)
```ini
[example.com]
user = example_user
group = example_user
listen = /run/php/php8.3-fpm-example.com.sock

# Only site-specific settings (defaults inherited from default.conf)
php_admin_value[open_basedir] = "/opt/magic/lib:/usr/share:/var/lib:/var/tmp:/home/example_user/domains/example.com:."
php_admin_value[upload_tmp_dir] = "/home/example_user/domains/example.com/tmp/www"
php_admin_value[session.save_path] = "/home/example_user/domains/example.com/tmp/www"
php_admin_value[sendmail_path] = "/usr/sbin/sendmail -t -i -f webmaster@example.com"
php_admin_value[error_log] = "/var/log/php/example.com.error.log"
slowlog = /var/log/php/example.com-slow.log
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
✅ **5 files per site max** - Apache, PHP conf, PHP pool.d, + Caddy files
