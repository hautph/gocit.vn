#!/bin/bash
# Messy script for zimbra password expiry email notification.
# Meant to be performed as daily cronjob run as zimbra user. 
# redirect output to a file to get a 'log file' of sorts.

# Time taken of script;
echo "$SECONDS Started on: $(date)"

# Set some vars:
# First notification in days, then last warning:
FIRST="7"
LAST="3"
# pass expiry in days
POLICY="90"
# Sent from:
FROM="postmaster@gocit.vn"
# Domain to check, e.g. 'example.com'; leave blank for all
DOMAIN=""
# Recipient who should receive an email with all expired accounts
ADMIN_RECIPIENT="postmaster@gocit.vn"

# Sendmail executable
SENDMAIL=$(ionice -c3 find /opt/zimbra/ -type f -iname sendmail)

# Get all users - it should run once only.
USERS=`/opt/zimbra/bin/zmprov -l gaa`;

#Todays date, in seconds:
DATE=$(date +%s)

# Iterate through them in for loop:
for USER in $USERS
 do
# When was the password set?
OBJECT="(&(objectClass=zimbraAccount)(mail=$USER))"
ZIMBRA_LDAP_PASSWORD=`su - zimbra -c "zmlocalconfig -s zimbra_ldap_password | cut -d ' ' -f3"`
LDAP_MASTER_URL=`su - zimbra -c "zmlocalconfig -s ldap_master_url | cut -d ' ' -f3"`
LDAPSEARCH=$(ionice -c3 find /opt/zimbra/ -type f -iname ldapsearch)
PASS_SET_DATE=`$LDAPSEARCH -H $LDAP_MASTER_URL -w $ZIMBRA_LDAP_PASSWORD -D uid=zimbra,cn=admins,cn=zimbra -x $OBJECT | grep zimbraPasswordModifiedTime: | cut -d " " -f 2 | cut -c 1-8`

# Make the date for expiry from now.
EXPIRES=$(date -d  "$PASS_SET_DATE $POLICY days" +%s)

# Now, how many days until that?
DEADLINE=$(( (($DATE - $EXPIRES)) / -86400 ))

# Email to send to victims, ahem - users...
SUBJECT="$USER - Your email password will expire $DEADLINE day"
BODY="
Dear $USER,

It is hereby notified that your Email password will expire in $DEADLINE days. Please change your Email password immediately via Web Mail:

  - Access: https://mail.gocit.vn

How to change the Email password:

1. Login to Web Mail according to the address above
2. Select the Preferences tab
3. On the General menu Sign in. click the Change Password button
4. Fill in the old password, new password & confirm your new password
5. Click the Change password button to replace it

Email account passwords consist of at least 8 characters, with alphanumeric combinations (uppercase, lowercase, numbers) and symbols (! @ # $, Etc.).

If you have questions about how to change your Email password, please contact the Support team


Thank you,
Postmaster
"
# Send it off depending on days, adding verbose statements for the 'log'
# First warning
if [[ "$DEADLINE" -eq "$FIRST" ]]
then
	echo "Subject: $SUBJECT" "$BODY" | $SENDMAIL -f "$FROM" "$USER"
	echo "Reminder email sent to: $USER - $DEADLINE days left" 
# Second
elif [[ "$DEADLINE" -eq "$LAST" ]]
then
	echo "Subject: $SUBJECT" "$BODY" | $SENDMAIL -f "$FROM" "$USER"
	echo "Reminder email sent to: $USER - $DEADLINE days left"
# Final
elif [[ "$DEADLINE" -eq "1" ]]
then
    echo "Subject: $SUBJECT" "$BODY" | $SENDMAIL -f "$FROM" "$USER"
	echo "Last chance for: $USER - $DEADLINE days left"
	
else 

    echo "Account: $USER reports; $DEADLINE days on Password policy"
fi

# Finish for loop
done

echo "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
