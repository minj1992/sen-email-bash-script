#############################


✅ Step 1: Install SSMTP

sudo apt-get update
sudo apt-get install -y ssmtp
✅ Step 2: Configure /etc/ssmtp/ssmtp.conf
Open the file:



sudo nano /etc/ssmtp/ssmtp.conf
Paste in this configuration:


# Email settings
root=minj1992@gmail.com
mailhub=smtp.gmail.com:587
AuthUser=minj1992@gmail.com
AuthPass=
UseSTARTTLS=YES
UseTLS=YES
FromLineOverride=YES
✔️ Notes:

AuthUser and AuthPass are your Gmail address and app password.

Gmail blocks normal passwords — this must be an App Password generated from your Google Account.

UseSTARTTLS=YES is necessary for port 587.


3##########################################




#!/bin/bash

# Disk usage threshold
THRESHOLD=80

# Email recipient
TO="minj1992@gmail.com"
SUBJECT="Disk Usage Report from $(hostname)"
EMAIL_FILE="/tmp/disk_usage_email.txt"

# Build disk usage body (excluding tmpfs, udev, loop)
{
  echo "Subject: $SUBJECT"
  echo "From: minj1992@gmail.com"
  echo "To: $TO"
  echo ""
  echo "🔔 Disk Usage Report on $(date):"
  echo ""
  df -hT | grep -vE '^tmpfs|^udev|^loop' | awk '{print $7, $6, $2, $3, $4}'
} > "$EMAIL_FILE"

# Send the email using ssmtp
ssmtp "$TO" < "$EMAIL_FILE"

# Clean up
rm -f "$EMAIL_FILE"
