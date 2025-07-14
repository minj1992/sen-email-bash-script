/*
Option 1: Use Gmail SMTP via msmtp (Recommended)
Instead of sending email directly from your server (which Gmail rejects), relay it through Gmail’s SMTP server using your Gmail credentials.

Here's how to set it up:

📨 Install msmtp:

sudo apt update
sudo apt install -y msmtp msmtp-mta mailutils


*/



#!/bin/bash

# Threshold in percent (e.g. 80 means alert if usage is 80% or more)
THRESHOLD=1

# Email settings
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="mi@gmail.com"
SMTP_PASS=""  # 🔒 Use an App Password, not your real Gmail password
FROM="min@gmail.com"
TO="mi92@gmail.com"
SUBJECT="Disk Usage Alert on $(hostname)"

# Temp files
BODY_FILE="/tmp/disk_body_$$.txt"
EMAIL_FILE="/tmp/email_$$.txt"

# Build body content
df -hP | awk 'NR>1 && $1 !~ /^tmpfs|^udev|^loop/ {print $5, $6}' | while read usage mountpoint; do
  percent=$(echo "$usage" | tr -d '%')
  if [ "$percent" -ge "$THRESHOLD" ]; then
    echo "Alert: $mountpoint is at $percent% usage." >> "$BODY_FILE"
  fi
done

# If alert generated, build full email and send
if [ -s "$BODY_FILE" ]; then
  {
    echo "Subject: $SUBJECT"
    echo "From: $FROM"
    echo "To: $TO"
    echo ""
    cat "$BODY_FILE"
  } > "$EMAIL_FILE"

  # Send email via msmtp
  msmtp --host=$SMTP_SERVER --port=$SMTP_PORT --auth=on \
        --tls=on --tls-starttls=on \
        --user="$SMTP_USER" --passwordeval="echo $SMTP_PASS" \
        --from="$FROM" "$TO" < "$EMAIL_FILE"
fi

# Cleanup
rm -f "$BODY_FILE" "$EMAIL_FILE"
