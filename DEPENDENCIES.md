# Karen Project Dependencies

## Network & Web Tools
- `curl` - HTTP requests (update-google-ips.sh, various install memos)
- `wget` - HTTP downloads (install memos)
- `socat` - Network utility (used in network tools)

## JSON Processing
- `jq` - JSON parsing (update-google-ips.sh)

## Development & Utilities
- `git` - Version control (install memos mention git)
- `rsync` - File synchronization (used in deploy scripts)
- `emacs`

## TLS/Certificate Management
- `certbot` - Let's Encrypt certificates (TLS certs used in mail templates)

## Internationalization
- `gettext` - Translation support (app/helpers/gettext checks for this)

## Package Management
- `apt` / `dpkg` - Debian package management (install memos)

## Optional/Context-Specific
- `unbound` - DNS resolver (to confirm for mail server)

## Service-Specific (when relevant)
- `php` - Web scripting (autodiscover.php, setup-php)
- `apache2` / `caddy` - Web servers (when using those features)
- `postfix` / `dovecot` - Mail servers (when using mail features)
- `mariadb` / `mysql` - Database (when using database features)

## Notes
- Most core tools are included in standard Debian installations
- Critical tools that might be missing: `gettext`, `curl`, `jq`, `lsb-release`
- Service-specific dependencies only needed when using those features
- Last updated: 2025-08-16
