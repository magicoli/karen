# TODO

## Anti-Spam Implementation Lessons Learned

### Key Findings from Recent Attempt:
- **Postfix duplicate entries**: Expected behavior - custom settings added at end for identification
- **Mail flow complexity**: local vs virtual vs content_filter interactions (procmail no longer involved)
- **SpamAssassin integration sequencing**: Critical - kills mail delivery if misconfigured
- **postfix-reload script**: Works for most databases but still has issues with `rbl_override` postmap rebuilding
- **Dovecot LMTP + Sieve**: Templates created and Sieve scripts compiled successfully
- **CRITICAL DISCOVERY**: Dovecot fails to restart with new template configuration

### Required Before Next Attempt:
- [ ] Setup sandbox mail server for safe testing
- [ ] Analyze complete mail flow: Postfix → SpamAssassin → Dovecot LMTP → Sieve
- [ ] Fix Dovecot template configuration issues preventing restart
- [ ] Resolve postmap permissions and database rebuilding problems
- [ ] Test content_filter sequencing thoroughly
- [ ] Develop staged deployment strategy with rollback procedures

### Template Infrastructure Status:
- [x] templates/dovecot/conf.d/ - Complete configuration split by functionality
- [x] templates/dovecot/sieve/ - Spam filtering and learning scripts
- [x] templates/postfix/ - SpamAssassin integration and RBL protection
- [ ] Validation: All templates must allow service restart before deployment

## Mail

Do in order, every step must be validated before the next one

- [x] Update template config to optimize spam protection
- [x] Create tools/update-google-ips.sh for Google IP maintenance
- [x] Configure junk mails to go in user Junk mailbox by default (overridable per-user)
- [x] Backup entire /etc/ folder
- [x] Test config with postfix check
- [ ] Deploy to production temporarily for quick test
- [ ] CRITICAL, WRONG SETUP - REVERTED TO STABLE CONFIG
    - mail processed by postfix but not properly delivered to spam assassin, 
    - postmap db files not updated
    - permission denied on `postmap /etc/postfix/rbl_override`
    - **Dovecot failed to restart with new template configuration**
- [x] Quickly go back to initial settings untill nothing goes wrong (I told you so!!!) ;-)
- [ ] Deploy to production for long test
    - [ ] Keep in production and wait for the phone to ring for clients complains
    - [ ] Evaluate the needs and advantages of integrating Amavis
- [ ] Adapt update-google-ips.sh for cron and add it for periodic updates
- [ ] Check if postfix-reload script is up-to-date and integrate in Karen environment

## Certificate Management
- [ ] Fix Let's Encrypt certificate path automation for mail services
  - Current issue: Postfix/Dovecot use hardcoded paths like `/etc/letsencrypt/live/mail.magiiic.com-0002/`
  - Problem: Certbot creates new numbered directories when domains change
  - Solutions to evaluate:
    - [ ] Compare existing scripts with tools/certbot-mail-deploy-hook.sh
    - [ ] Implement stable symlink approach (/etc/ssl/mail-certs -> current cert)
    - [ ] Integrate with Karen deployment system
    - [ ] Test automatic reload of mail services

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
