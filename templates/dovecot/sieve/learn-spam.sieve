#!/usr/bin/env sieve
# Learn spam when user moves mail TO Junk folder
# Place in: /etc/dovecot/sieve/learn-spam.sieve

require ["vnd.dovecot.pipe", "copy", "imapsieve"];

pipe :copy "sa-learn-spam.sh";
