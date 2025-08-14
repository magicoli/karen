# Karen Build Directory

This directory contains files that are **generated automatically** by Karen and copied automatically to their target locations.

## Purpose
- Contains processed templates and generated configuration files
- Files here are ready to be deployed to their final destinations in `/etc/`
- Acts as a staging area for generated content

## Important Notes
- **This directory can be deleted at any time** - it will be regenerated as needed
- **Do not edit files here manually** - they will be overwritten
- **Not tracked in git** - contents are generated, not source files
- Files are automatically copied to target locations after generation

## Typical Contents
- Processed PHP-FPM pool configurations
- Generated Apache/Caddy site configurations
- Compiled systemd service files
- Any other configuration files created from templates

## Lifecycle
1. Karen processes templates with user-specific data
2. Generated files are placed here
3. Files are automatically copied to `/etc/` or other target locations
4. Directory can be cleaned up after deployment
