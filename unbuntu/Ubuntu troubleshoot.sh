#!/bin/bash
# --------------------------------------------------
# Basic Linux Troubleshooting Script
#
# Purpose:
# Collects basic system information and saves it
# in a troubleshooting report.
#
# Requirements:
# - Bash shell
# - ip and ss commands (iproute2 package)
# - systemctl (systemd)
# - logrotate
# - A user account with permission to run the
#   logrotate check with sudo
#
# Before running:
# 1. Save this file as troubleshoot.sh.
# 2. Make it executable:
#    chmod +x ~/troubleshoot.sh
# 3. Run it:
#    ~/troubleshoot.sh
#
# The report is saved as:
# ~/troubleshooting-report.txt
#
# Cron note:
# The logrotate command uses sudo. For automatic
# cron runs, configure appropriate non-interactive
# permissions or run the job with the required
# privileges. Do not assume an interactive sudo
# password prompt will work from cron.
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
