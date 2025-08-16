#!/usr/bin/env sieve
# Learn ham when user moves mail FROM Junk folder
# Place in: /etc/dovecot/sieve/learn-ham.sieve

require ["vnd.dovecot.pipe", "copy", "imapsieve"];

pipe :copy "sa-learn-ham.sh";
