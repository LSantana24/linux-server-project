#!/bin/bash

# Basic Linux Troubleshooting Script

REPORT="$HOME/troubleshooting-report.txt"

echo "Linux Troubleshooting Report" > "$REPORT"
echo "Date: $(date)" >> "$REPORT"
echo "Hostname: $(hostname)" >> "$REPORT"

echo "" >> "$REPORT"
echo "LINUX VERSION" >> "$REPORT"
cat /etc/os-release >> "$REPORT"

echo "" >> "$REPORT"
echo "NETWORK INFORMATION" >> "$REPORT"
ip addr >> "$REPORT"
ip route >> "$REPORT"

echo "" >> "$REPORT"
echo "DNS SETTINGS" >> "$REPORT"
cat /etc/resolv.conf >> "$REPORT"

echo "" >> "$REPORT"
echo "DISK SPACE" >> "$REPORT"
df -h >> "$REPORT"

echo "" >> "$REPORT"
echo "FAILED SERVICES" >> "$REPORT"
systemctl --failed >> "$REPORT" 2>&1

echo "" >> "$REPORT"
echo "LISTENING PORTS" >> "$REPORT"
ss -tuln >> "$REPORT"

echo "" >> "$REPORT"
echo "LOGROTATE CONFIGURATION CHECK" >> "$REPORT"
sudo logrotate -d /etc/logrotate.conf >> "$REPORT" 2>&1

echo "" >> "$REPORT"
echo "Troubleshooting report completed."
echo "Report saved to $REPORT"
