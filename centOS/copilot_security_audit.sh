#!/bin/bash

# Security Audit Script
# Reports:
# - Failed SSH logins from last 24 hours
# - UID 0 accounts
# - Accounts with empty passwords
# - Listening ports using ss
# Saves results to timestamped files
# Exits non-zero if problems are found

PATH=/usr/sbin:/usr/bin:/sbin:/bin

REPORT_DIR="/var/log/security_audit"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
REPORT_FILE="${REPORT_DIR}/security_audit_${TIMESTAMP}.txt"

PROBLEMS=0

mkdir -p "$REPORT_DIR" || {
    echo "ERROR: Unable to create report directory."
    exit 2
}

{
    echo "========================================="
    echo "Security Audit Report"
    echo "Generated: $(date)"
    echo "Hostname: $(hostname)"
    echo "========================================="
    echo

    echo "==== FAILED SSH LOGINS (LAST 24 HOURS) ===="

    if command -v journalctl >/dev/null 2>&1; then
        FAILED_SSH=$(journalctl --since "24 hours ago" 2>/dev/null | \
            grep -i "failed password")
    else
        FAILED_SSH=$(find /var/log -type f -name "auth.log*" -o -name "secure*" 2>/dev/null | \
            xargs grep -i "failed password" 2>/dev/null)
    fi

    if [ -n "$FAILED_SSH" ]; then
        echo "$FAILED_SSH"
        PROBLEMS=1
    else
        echo "No failed SSH logins found."
    fi

    echo
    echo "==== UID 0 ACCOUNTS ===="

    UID0_ACCOUNTS=$(awk -F: '$3 == 0 {print $1}' /etc/passwd)

    echo "$UID0_ACCOUNTS"

    UID0_COUNT=$(echo "$UID0_ACCOUNTS" | wc -l)

    if [ "$UID0_COUNT" -gt 1 ]; then
        echo
        echo "WARNING: Multiple UID 0 accounts detected."
        PROBLEMS=1
    fi

    echo
    echo "==== ACCOUNTS WITH EMPTY PASSWORDS ===="

    EMPTY_PASSWORDS=$(
        awk -F: '($2==""){print $1}' /etc/shadow 2>/dev/null
    )

    if [ -n "$EMPTY_PASSWORDS" ]; then
        echo "$EMPTY_PASSWORDS"
        PROBLEMS=1
    else
        echo "No empty-password accounts found."
    fi

    echo
    echo "==== LISTENING PORTS ===="

    if command -v ss >/dev/null 2>&1; then
        ss -tuln
    else
        echo "ss command not found."
        PROBLEMS=1
    fi

    echo
    echo "==== AUDIT COMPLETE ===="

} > "$REPORT_FILE"

if [ "$PROBLEMS" -eq 0 ]; then
    echo "Audit completed successfully."
    echo "Report: $REPORT_FILE"
    exit 0
else
    echo "Issues found."
    echo "Report: $REPORT_FILE"
    exit 1
fi
