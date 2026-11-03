#!/usr/bin/env bash
# CIS 245 security-audit script draft. AI-generated starting point; test on both lab servers.
# Bash syntax and exit statuses: https://www.gnu.org/software/bash/manual/bash.html
# journalctl options and time filtering: https://man7.org/linux/man-pages/man1/journalctl.1.html
# passwd account-file fields: https://man7.org/linux/man-pages/man5/passwd.5.html
# shadow password-field meanings: https://man7.org/linux/man-pages/man5/shadow.5.html
# ss listening-socket options: https://man7.org/linux/man-pages/man8/ss.8.html
# cron environment considerations: https://man7.org/linux/man-pages/man5/crontab.5.html

# Use a predictable PATH for non-interactive runs; Bash manual above documents environment behavior.
PATH=/usr/sbin:/usr/bin:/sbin:/bin
export PATH
# Create private files by default; Bash umask documentation is in the Bash manual above.
umask 077

# Require root to read protected account data and collect process details; see passwd(5), shadow(5), and ss(8).
if [ "$(id -u)" -ne 0 ]; then
    printf 'ERROR: Run with sudo, for example: sudo %s\n' "$0" >&2
    exit 2
fi

# Verify required standard utilities without installing anything; command -v is a Bash builtin.
for cmd in date hostname journalctl awk ss grep mkdir touch chmod; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'ERROR: Required command not found: %s\n' "$cmd" >&2
        exit 2
    fi
done

# Store output outside /tmp in a private directory; mkdir(1), date(1), hostname(1) and chmod(1) references are in their local man pages.
REPORT_DIR='/var/log/server-security-audit'
STAMP="$(date '+%Y%m%d_%H%M%S')"
HOST="$(hostname -s 2>/dev/null || hostname)"
REPORT_FILE="${REPORT_DIR}/security_audit_${HOST}_${STAMP}.txt"
if ! mkdir -p "$REPORT_DIR"; then
    printf 'ERROR: Cannot create report directory: %s\n' "$REPORT_DIR" >&2
    exit 2
fi
if ! touch "$REPORT_FILE" || ! chmod 600 "$REPORT_FILE"; then
    printf 'ERROR: Cannot create or secure report: %s\n' "$REPORT_FILE" >&2
    exit 2
fi

# A report is a finding when a security concern or a required check failure is found.
PROBLEM_FOUND=0
{
    printf 'SERVER SECURITY AUDIT\n'
    printf 'Hostname: %s\n' "$HOST"
    printf 'Date: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
    printf 'Report: %s\n\n' "$REPORT_FILE"

    # journalctl(1): query the previous 24 hours. Check journalctl's status separately from grep's no-match status.
    printf '%s\n' '1. Failed SSH login attempts in the last 24 hours'
    SSH_LOGS="$(journalctl --since '24 hours ago' --no-pager -o short-iso 2>&1)"
    JOURNAL_STATUS=$?
    if [ "$JOURNAL_STATUS" -ne 0 ]; then
        printf 'ERROR: journalctl failed (status %s); SSH-log check is incomplete.\n' "$JOURNAL_STATUS"
        PROBLEM_FOUND=1
    else
        SSH_FAILURES="$(printf '%s\n' "$SSH_LOGS" | grep -Ei 'sshd.*(failed password|authentication failure|invalid user|maximum authentication attempts|failed publickey)' || true)"
        if [ -n "$SSH_FAILURES" ]; then
            printf '%s\n' "$SSH_FAILURES"
            printf '%s\n' 'WARNING: Failed SSH login events were found; review them.'
            PROBLEM_FOUND=1
        else
            printf '%s\n' 'No matching SSH failure messages were found in the available system journal.'
        fi
    fi
    printf '\n'

    # passwd(5): UID is field 3; UID 0 accounts have superuser privileges.
    printf '%s\n' '2. Accounts with UID 0'
    UID0_ACCOUNTS="$(awk -F: '$3 == 0 {print $1 " (UID " $3 ")"}' /etc/passwd)"
    if [ -z "$UID0_ACCOUNTS" ]; then
        printf '%s\n' 'ERROR: No UID 0 account found in /etc/passwd.'
        PROBLEM_FOUND=1
    else
        printf '%s\n' "$UID0_ACCOUNTS"
        EXTRA_UID0="$(awk -F: '$3 == 0 && $1 != "root" {print $1}' /etc/passwd)"
        if [ -n "$EXTRA_UID0" ]; then
            printf 'WARNING: UID 0 account(s) other than root: %s\n' "$EXTRA_UID0"
            PROBLEM_FOUND=1
        fi
    fi
    printf '\n'

    # shadow(5): field 2 is the password hash/status; only a truly empty field is reported here.
    printf '%s\n' '3. Accounts with empty password fields'
    if [ ! -r /etc/shadow ]; then
        printf '%s\n' 'ERROR: /etc/shadow is not readable; this check is incomplete.'
        PROBLEM_FOUND=1
    else
        EMPTY_PASSWORDS="$(awk -F: 'NF >= 2 && $2 == "" {print $1}' /etc/shadow)"
        if [ -n "$EMPTY_PASSWORDS" ]; then
            printf '%s\n' "$EMPTY_PASSWORDS"
            printf '%s\n' 'WARNING: Accounts with empty password fields were found.'
            PROBLEM_FOUND=1
        else
            printf '%s\n' 'No accounts with empty password fields were found.'
        fi
    fi
    printf '\n'

    # ss(8): -l listening, -n numeric, -t TCP, -u UDP, -p process details.
    printf '%s\n' '4. Listening TCP/UDP ports (ss -lntup)'
    ss -lntup
    SS_STATUS=$?
    if [ "$SS_STATUS" -ne 0 ]; then
        printf 'ERROR: ss failed with status %s; listening-port check is incomplete.\n' "$SS_STATUS"
        PROBLEM_FOUND=1
    fi
    printf '\n'

    # State important limits so a clean-looking report is not mistaken for a guarantee of security.
    printf '%s\n' 'Notes:'
    printf '%s\n' '- Local account checks use /etc/passwd and /etc/shadow; external identity sources may need separate checks.'
    printf '%s\n' '- SSH failures are searched in the systemd journal; log retention and service logging affect coverage.'
    printf '%s\n' '- Failed login events warrant review but do not alone prove a successful compromise.'
} >> "$REPORT_FILE" 2>&1

# Bash printf and exit-status behavior: see the Bash manual linked at the top.
printf 'Audit report saved to: %s\n' "$REPORT_FILE"
if [ "$PROBLEM_FOUND" -ne 0 ]; then
    exit 1
fi
exit 0
