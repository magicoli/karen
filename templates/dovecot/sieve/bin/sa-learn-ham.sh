#!/bin/bash
# SpamAssassin learning script for ham
# Place in: /etc/dovecot/sieve/bin/sa-learn-ham.sh
# Make executable: chmod +x /etc/dovecot/sieve/bin/sa-learn-ham.sh

exec /usr/bin/sa-learn --ham --no-sync
