✅ Works with an SMTP server that allows sending without username/password (e.g., an internal mail relay).

🛡️ Warning: Gmail's SMTP does not allow this — this works only if your SMTP server accepts unauthenticated mail on the specified port (commonly port 25 or 587 without auth).

✅ diskcheck.sh (No authentication)

bash
Copy
Edit
#!/bin/bash

# === CONFIGURATION ===

# Disk usage threshold in percent
THRESHOLD=80

# SMTP settings (unauthenticated)
SMTP_SERVER="your.smtp.server.com"   # Replace with your org's SMTP server (not Gmail)
SMTP_PORT="25"                       # Or 587, or whatever your relay uses (often 25 for no auth)
FROM="alerts@yourdomain.com"
TO="you@yourdomain.com"
SUBJECT="Disk Usage Alert from $(hostname)"
LOGFILE="/tmp/msmtp.log"

# === TEMP FILES ===
BODY_FILE="/tmp/disk_alert_body_$$.txt"
EMAIL_FILE="/tmp/disk_alert_email_$$.txt"

# === BUILD DISK ALERT BODY ===
df -hP | awk 'NR>1 && $1 !~ /^tmpfs|^udev|^loop/ {print $5, $6}' | while read usage mount; do
  percent=$(echo "$usage" | tr -d '%')
  if [ "$percent" -ge "$THRESHOLD" ]; then
    echo "⚠️ Partition $mount is at $percent% usage." >> "$BODY_FILE"
  fi
done

# === SEND EMAIL IF ALERT GENERATED ===
if [ -s "$BODY_FILE" ]; then
  {
    echo "Subject: $SUBJECT"
    echo "From: $FROM"
    echo "To: $TO"
    echo ""
    cat "$BODY_FILE"
  } > "$EMAIL_FILE"

  # Send the email using msmtp without authentication
  msmtp --host="$SMTP_SERVER" \
        --port="$SMTP_PORT" \
        --from="$FROM" \
        --logfile="$LOGFILE" \
        "$TO" < "$EMAIL_FILE"

  echo "✅ Email sent. Log: $LOGFILE"
else
  echo "✅ No partitions exceeded ${THRESHOLD}%. No email sent."
fi

# === CLEANUP ===
rm -f "$BODY_FILE" "$EMAIL_FILE"
—

📌 Notes:

Replace your.smtp.server.com with your actual internal or corporate SMTP host (e.g., smtp.relay.company.com)

Adjust the port if required (port 25 is usually for unauthenticated mail relays).

This script will fail silently if the SMTP server still expects authentication — check /tmp/msmtp.log after running.
