# TODO

## Mail

Do in order, every step must be validated before the next one

- [x] Update template config to optimize spam protection
- [x] Create tools/update-google-ips.sh for Google IP maintenance
- [ ] Configure junk mails to go in user Junk mailbox by default (overridable per-user)
- [ ] Backup entire /etc/ folder
- [ ] Test config with postfix check
- [ ] Deploy to production temporarily for quick test
- [ ] Quickly go back to initial settings untill nothing goes wrong
- [ ] Deploy to production for long test
    - [ ] Keep in production and wait for the phone to ring for clients complains
    - [ ] Evaluate the needs and advantages of integrating Amavis
- [ ] Adapt update-google-ips.sh for cron and add it for periodic updates

**Once everyting is stable**
- [ ] Migrate web server to Caddy (this time, I will need a test server)
- [ ] Cleanup obsolete packages

```bash
# Remove GUI packages (keep imagemagick for Roundcube)
apt remove --purge adwaita-icon-theme gtk-update-icon-cache hicolor-icon-theme \
  fonts-dejavu-core fontconfig fontconfig-config emacs-gtk \
  libgtk-3-* libgdk-pixbuf* libx11-* x11-common

# Remove after migrating to Caddy
apt remove --purge apache2 apache2-* memcached

# Check if imagemagick is actually used by Roundcube before removing:
# grep -r imagick /etc/roundcube/ /var/lib/roundcube/
# If not used: apt remove --purge imagemagick imagemagick-6-* libmagick*
```


## Dependency list
- jq
- unbound (to confirm, for mail server?)

## Notes
- See DEPENDENCIES.md for complete project dependency analysis
