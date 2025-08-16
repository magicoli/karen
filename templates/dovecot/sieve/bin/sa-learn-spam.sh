#!/bin/bash
# SpamAssassin learning script for spam
# Place in: /etc/dovecot/sieve/bin/sa-learn-spam.sh
# Make executable: chmod +x /etc/dovecot/sieve/bin/sa-learn-spam.sh

exec /usr/bin/sa-learn --spam --no-sync
