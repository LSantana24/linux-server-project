#!/bin/bash

# Network Information Dump Script
# This script collects basic network information
# and saves it to a text file in your home directory.
#
# HOW TO RUN THIS SCRIPT:
# 1. Save this file as network_info_dump.sh
# 2. Open a terminal in the folder where you saved it.
# 3. Make the script executable by typing:
#       chmod +x network_info_dump.sh
# 4. Run the script by typing:
#       ./network_info_dump.sh
#
# The report will be saved in the network_reports
# folder inside your home directory.

# Create the folder for the reports if it does not exist.
mkdir -p "$HOME/network_reports"

# Create a report filename using the server name and date.
REPORT="$HOME/network_reports/network_info_$(hostname)-$(date +%F).txt"

# Collect the network information and save it to the report.
{
    # Shows the report title and current date.
    echo "My network info"
    date
    echo

    # Shows the installed Linux version.
    echo "Linux Version:"
    cat /etc/os-release
    echo

    # Shows network interfaces and IP addresses.
    echo "IP Address:"
    ip addr show
    echo

    # Shows network routes and the default gateway.
    echo "Network Gateway:"
    ip route
    echo

    # Shows DNS information.
    echo "DNS Settings:"
    resolvectl status
    echo

    # Show the server's hostname.
    echo "Server Name:"
    hostname

} > "$REPORT"


# Tell the user where the report was saved.
echo
echo "The report was saved to $REPORT"
