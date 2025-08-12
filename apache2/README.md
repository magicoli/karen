# Apache Performance Optimization Structure

This directory contains a performance-optimized Apache configuration following the same minimalist principles as the Caddy setup.

## Philosophy

- **One minimal file per site** - using macros and snippets
- **Shared configuration** - identical across dev/prod servers  
- **Environment-specific settings** - handled by symlinks/defines
- **Application-specific snippets** - reusable components

## Structure

```
/opt/magic/etc/
├── apache2/
│   ├── conf/
│   │   ├── macros.conf                    # Main macros (VHostPHP, VHostWordPress, etc.)
│   │   └── performance-environment.conf   # Environment detection & settings
│   ├── snippets/
│   │   ├── logging.conf                   # Enhanced logging
│   │   ├── security-headers.conf          # Security headers
│   │   ├── static-files.conf              # Caching & compression
│   │   ├── php-fpm.conf                   # PHP-FPM handling
│   │   ├── wordpress.conf                 # WordPress-specific rules (minimal)
│   │   ├── nextcloud-app.conf             # Nextcloud/Owncloud rules  
│   │   ├── roundcube.conf                 # Roundcube webmail rules
│   │   ├── wrap-app.conf                  # Magic Wrap CMS rules
│   │   └── angstk.conf                    # Angstk framework rules
│   └── sites/
│       ├── gites-mosaiques.com-clean.conf # Example clean site config
│       └── ...
└── php/
    └── 8.3/fmp/
        ├── conf/
        │   ├── magiiic-defaults.ini       # Generic PHP settings
        │   ├── magiiic-dev.ini            # Development-only settings
        │   └── magiiic-prod.ini           # Production-only settings
        └── pool.d/
            ├── gites-mosaiques.com-clean.conf  # Minimal pool config
            └── ...
```

## Usage

### 1. Site Configuration

Create a minimal Apache site config:

```apache
# mysite.com - Apache Configuration
Use VHostWordPress mysite mysite.com /path/to/docroot

# Site-specific overrides (optional)
<VirtualHost *:443>
  ServerName mysite.com
  Define SITE_SOCKET  # Use dedicated PHP-FPM pool
  
  # Any site-specific customizations
  # IncludeOptional /opt/magic/etc/apache2/snippets/nextcloud-app.conf
</VirtualHost>
```

### 2. PHP Pool Configuration  

Create a minimal PHP-FPM pool:

```ini
[mysite.com]
user = myuser
group = myuser  
listen = /run/php/php8.3-fpm-mysite.com.sock
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

pm = dynamic
pm.max_children = 20
pm.start_servers = 4
pm.min_spare_servers = 2  
pm.max_spare_servers = 6
pm.max_requests = 1000

# Site-specific settings (these MUST be in pool config)
php_admin_value[open_basedir] = "/opt/magic/lib:/usr/share:/var/lib:/var/tmp:/path/to/site:."
php_admin_value[upload_tmp_dir] = "/path/to/site/tmp"
php_admin_value[session.save_path] = "/path/to/site/tmp"
php_admin_value[sendmail_path] = "/usr/sbin/sendmail -t -i -f webmaster@mysite.com"
php_admin_value[error_log] = "/var/log/php/mysite.com.error.log"
```

### 3. Environment Setup

Run the setup script to configure for your environment:

```bash
sudo /opt/magic/etc/setup-apache-optimization.sh
```

This automatically detects dev vs prod and sets up the right PHP configuration files.

## Available Macros

- **`VHostPHP site server docroot`** - Basic PHP site
- **`VHostWordPress site server docroot`** - WordPress site (includes WordPress snippet)  
- **`VHostStatic site server docroot`** - Static files only

## Available Snippets

- **`wordpress.conf`** - WordPress security rules
- **`nextcloud-app.conf`** - Nextcloud/Owncloud application rules
- **`roundcube.conf`** - Roundcube webmail rules  
- **`wrap-app.conf`** - Magic Wrap CMS framework rules
- **`angstk.conf`** - Angstk framework rules

Include snippets as needed:
```apache
IncludeOptional /opt/magic/etc/apache2/snippets/nextcloud-app.conf
```

## Key Differences from Old Setup

### Removed
- `mpm_itk` and `AssignUserID` (replaced by PHP-FPM pools)
- `mod_php` (replaced by `proxy_fcgi`)
- Per-site PHP settings in Apache (moved to PHP-FPM pools)
- Complex per-site Apache configurations

### Added  
- **Unified macro system** - consistent site setup
- **Shared snippets** - reusable application rules
- **Environment detection** - automatic dev/prod handling
- **Performance optimization** - HTTP/2, compression, caching
- **Security hardening** - modern headers, file restrictions

## Environment Detection

The system automatically detects environment:
- **Production**: Has `/etc/letsencrypt/live/` with certificates
- **Development**: No certificates, uses self-signed

### Development Environment
- OPcache disabled
- Error display enabled  
- No caching headers
- Debug headers added

### Production Environment  
- OPcache optimized
- Errors logged only
- Aggressive caching
- OCSP stapling enabled

## Migration Guide

1. **Backup existing configs**
2. **Deploy new structure** with `setup-apache-optimization.sh`
3. **Convert sites one by one**:
   - Replace complex Apache config with macro call
   - Move PHP settings to FPM pool config  
   - Test functionality
4. **Enable new site** and **disable old**
5. **Monitor performance**

## PHP Configuration Hierarchy

1. **Global PHP settings** (`/etc/php/8.3/fpm/php.ini`)  
2. **Magic defaults** (`magiiic-defaults.ini`) - upload limits, etc.
3. **Environment settings** (`magiiic-dev.ini` OR `magiiic-prod.ini`)
4. **Pool overrides** (in `pool.d/*.conf`) - **these win!**

**Important**: Settings like `session.save_path`, `open_basedir`, and `upload_tmp_dir` can ONLY be set properly in pool configs, not in conf files.

## Benefits

- **Performance**: PHP-FPM is faster than mod_php
- **Security**: Better process isolation  
- **Maintainability**: Consistent, minimal configs
- **Scalability**: Easy to add sites
- **Deployment**: Same configs work on dev and prod
- **Debugging**: Clear separation of concerns
