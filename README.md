# Karen - Kickass Admin Resource Entitlement Normalizer

> Normalizing admin wrongs since 1994.  
> *Warning: this app only speaks to the manager.*

## Description

Karen is a lightweight server configuration management system that simplifies the deployment and management of web server configurations.

## Features

- **Automatic Installation**: Smart environment detection and setup
- **Modular Architecture**: Clean separation with app/helpers/ system  
- **Bash Completion**: Full command-line completion support
- **Simple Commands**: Streamlined interface (`karen php`, `karen apache`, `karen caddy`)
- **Environment Management**: Easy switching between development and production

## Installation

Karen automatically initializes itself on first run. Simply run any command and follow the prompts:

```bash
./karen php development
```

## Commands

```bash
karen help                    # Show detailed help
karen php [env] [action]      # Configure PHP-FPM pools
karen caddy [env] [action]    # Generate Caddy configurations  
karen apache [env] [action]   # Configure Apache optimizations
```

**Environments**: `development`, `production`  
**Actions**: `reload`, `restart`

## Examples

```bash
karen php development          # Setup PHP for development
karen apache production reload # Setup Apache for production and reload
karen caddy development        # Setup Caddy for development
```

## Directory Structure

```
karen/
├── app/
│   ├── helpers/          # Core helper functions (init, utils, defaults)
│   └── doc/             # Usage and help documentation
├── presets/             # Ready-to-use configurations (link to /etc/)
├── templates/           # Customizable templates (require modification)
├── bin/                 # Utility scripts
└── karen                # Main executable
```

## Configuration

Karen uses a simple environment file (`.env`) for configuration. All settings are auto-detected and configured on first run with user confirmation.

## Bash Completion

Install bash completion system-wide:

```bash
sudo ln -sf $(pwd)/presets/bash_completion.d/karen /etc/bash_completion.d/karen
```

## Architecture Notes

- **Presets**: Ready-to-link configurations (usually distribution defaults)
- **Templates**: Files requiring customization before use  
- **No flat structure**: Templates/presets mirror their target structure in `/etc/`

## Future Plans

- Web admin interface via Laravel/AGNSTK framework
- REST API for remote management  
- Object-oriented PHP backend for complex site relationships

## License

AGPL-3.0
