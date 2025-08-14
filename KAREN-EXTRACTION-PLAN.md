# Karen (Kickass Admin Resource Entitlement Normalizer) - Extraction Plan

## Complete File Inventory for Karen Repository

### 1. Executable Scripts (bash shebangs from grep -rl "/bin/bash")
```
apache2/tools/setup-apache-optimization.sh
apache2/tools/a2endev
apache2/tools/a2enprod
apache2/tools/ssl-info
apache2/tools/deploy-apache-optimization.sh
apache2/tools/a2toggle
caddy/tools/setup-caddy
caddy/tools/c2endev
caddy/tools/c2enprod
php/tools/generate-caddy-pools
php/tools/setup-php
tools/monitor-web-performances
wordpress/boilerplate/bin/minphp
wordpress/boilerplate/bin/wp-build.sh
deploy-optimizations.sh
```

### 2. Templates and Configuration Patterns
```
apache2/sites/_template.conf
caddy/sites/_template.caddyfile
php/8.3/fpm/pool.d/development.conf
php/8.3/fpm/pool.d/template-caddy-development.conf
php/8.3/fpm/pool.d/template-caddy-production.conf
php/8.3/fpm/pool.d/www.conf
```

### 3. Shell Libraries and Helpers
```
profile.d/0-helpers.sh
profile.d/1-magic.sh
profile.d/colors-ls.sh
profile.d/colors-prompt.sh
profile.d/debug.sh
```

### 4. Completion Scripts
```
bash_completion.d/brew
bash_completion.d/composer-completion.bash
bash_completion.d/domains-completion
bash_completion.d/ssh
bash_completion.d/wp-completion.bash
```

### 5. WordPress Scripts (Essential Only)
```
wordpress/boilerplate/bin/minphp
wordpress/boilerplate/bin/wp-build.sh
```

### 6. Mail Autoconfig (Complete Directory)
```
autoconfig/mail/config-v1.1-mozilla.xml
autoconfig/mail/config-v1.1-documented.xml
autoconfig/mail/config-v1.1.xml
autoconfig/autoconfig.cgi
autoconfig/autodiscover/autodiscover.xml
autoconfig/autodiscover/autodiscover.php
```

### 7. Other Shell Scripts
```
cleanup-structure.sh
deploy-apache-optimization.sh  
setup-apache-optimization.sh
```

### 8. System Integration
```
systemd/system/php8.3-fpm.service.d/caddy-pools.conf
```

## Proposed Karen Repository Structure
```
karen/
├── README.md
├── bin/                              # Main executables
│   ├── karen                        # Main CLI wrapper
│   ├── setup-apache
│   ├── setup-caddy  
│   ├── setup-php
│   ├── generate-caddy-pools
│   ├── a2endev, a2enprod, a2toggle
│   ├── c2endev, c2enprod
│   ├── deploy-optimizations
│   └── monitor-web-performances
├── lib/                             # Shared libraries
│   ├── helpers.sh                   # From profile.d/0-helpers.sh
│   ├── magic.sh                     # From profile.d/1-magic.sh
│   ├── colors.sh                    # Combined color utilities
│   └── debug.sh
├── templates/                       # All configuration templates
│   ├── apache2/
│   │   └── sites/_template.conf
│   ├── caddy/
│   │   └── sites/_template.caddyfile
│   ├── php/
│   │   ├── pool-caddy-development.conf.template
│   │   └── pool-caddy-production.conf.template
│   └── systemd/
│       └── php8.3-fpm.service.d/
├── completion/                      # Bash completion
│   ├── karen-completion.bash
│   ├── apache-completion.bash
│   ├── caddy-completion.bash
│   └── composer-completion.bash
├── autoconfig/                      # Mail autoconfig (complete)
│   ├── mail/
│   ├── autodiscover/
│   └── autoconfig.cgi
├── wordpress/                       # WordPress essential scripts only
│   ├── minphp
│   └── wp-build.sh
└── examples/                        # Example configurations
    └── sites/
```

## Migration Strategy
1. **Phase 1**: Create Karen repo structure
2. **Phase 2**: Copy files maintaining their relative paths
3. **Phase 3**: Create main `karen` CLI wrapper
4. **Phase 4**: Test Karen independently
5. **Phase 5**: Update this repo to use Karen as dependency

## Files That Stay in Config Repo
- Actual site configurations (apache2/sites/*.conf, caddy/sites/*.caddyfile)
- Server-specific settings (mysql/, dovecot/, fail2ban/ etc.)
- Environment-specific files (bashrc, profile, servers)
- SSL certificates and keys
- UFW rules, SSH configs, sudoers
