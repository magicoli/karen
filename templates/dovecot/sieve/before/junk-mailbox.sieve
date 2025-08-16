# Global spam filtering rules - executed before user rules
# Place in: /etc/dovecot/sieve/before/junk-mailbox.sieve
# Compile with: sievec /etc/dovecot/sieve/before/junk-mailbox.sieve

require ["fileinto", "imap4flags"];

# Move spam to Junk folder
if header :contains "X-Spam-Status" "Yes" {
    fileinto "Junk";
    setflag "\\Seen";
    stop;
}

# Note: Users can override by creating ~/.dovecot.sieve 
# See user.dovecot.sive.example for details
