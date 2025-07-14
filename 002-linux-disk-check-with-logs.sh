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
SMTP_USER="mi2@gmail.com"
SMTP_PASS=""  # 🔒 Use an App Password, not your real Gmail password
FROM="mi2@gmail.com"
TO="mi2@gmail.com"
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

root@node2:/home/ubuntu# cat test1.sh
#!/bin/bash

# === CONFIGURATION ===

# Disk usage threshold in percent
THRESHOLD=2

# Gmail SMTP settings
SMTP_SERVER="smtp.gmail.com"
SMTP_PORT="587"
SMTP_USER="minj1992@gmail.com"
SMTP_PASS="qdwtynglfmclestj"  # App Password, not Gmail login
FROM="minj1992@gmail.com"
TO="minj1992@gmail.com"
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

  # Send the email using msmtp
  msmtp --host="$SMTP_SERVER" \
        --port="$SMTP_PORT" \
        --auth=on \
        --tls=on \
        --tls-starttls=on \
        --user="$SMTP_USER" \
        --passwordeval="echo $SMTP_PASS" \
        --from="$FROM" \
        --logfile="$LOGFILE" \
        "$TO" < "$EMAIL_FILE"

  echo "✅ Email sent. Log: $LOGFILE"
else
  echo "✅ No partitions exceeded ${THRESHOLD}%. No email sent."
fi

# === CLEANUP ===
rm -f "$BODY_FILE" "$EMAIL_FILE"
