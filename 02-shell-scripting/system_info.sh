#!/bin/bash
#
# system_info.sh — System Information Script
#
# Homework task: print the date, hostname, username, disk usage and running
# processes; use variables; take input with `read -p`; create a directory with
# `mkdir`; create a file with `touch`; and save the process list to that file
# using `>` output redirection.
#
# Usage:  ./system_info.sh
#         echo "reports" | ./system_info.sh      # non-interactive

# ---------------------------------------------------------------
# 1. Store the system information in variables
# ---------------------------------------------------------------
CURRENT_DATE=$(date)
HOST_NAME=$(hostname)
USER_NAME=$(whoami)
DISK_USAGE=$(df -h)
PROCESS_LIST=$(ps aux)

# ---------------------------------------------------------------
# 2. Print the information using the variables
# ---------------------------------------------------------------
echo "=============================================="
echo "           SYSTEM INFORMATION REPORT          "
echo "=============================================="
echo ""

echo "Current Date : $CURRENT_DATE"
echo "Hostname     : $HOST_NAME"
echo "Username     : $USER_NAME"
echo ""

echo "----------------- DISK USAGE -----------------"
echo "$DISK_USAGE"
echo ""

echo "-------- RUNNING PROCESSES (top 10) ----------"
echo "$PROCESS_LIST" | head -n 10
echo ""

# ---------------------------------------------------------------
# 3. Take user input with read -p
# ---------------------------------------------------------------
read -p "Enter a name for the report directory: " DIR_NAME

# Fall back to a default if the user just pressed Enter
if [ -z "$DIR_NAME" ]; then
    DIR_NAME="system_report"
    echo "No name entered, using default directory: $DIR_NAME"
fi

# ---------------------------------------------------------------
# 4. Create the directory (mkdir) and the file (touch)
# ---------------------------------------------------------------
FILE_NAME="processes.txt"

mkdir -p "$DIR_NAME"
echo "Directory created: $DIR_NAME"

touch "$DIR_NAME/$FILE_NAME"
echo "File created    : $DIR_NAME/$FILE_NAME"

# ---------------------------------------------------------------
# 5. Store the running processes in the file with > redirection
# ---------------------------------------------------------------
ps aux > "$DIR_NAME/$FILE_NAME"

echo ""
echo "Running processes saved to $DIR_NAME/$FILE_NAME"
echo "Lines written: $(wc -l < "$DIR_NAME/$FILE_NAME")"
echo ""
echo "First 5 lines of the saved file:"
head -n 5 "$DIR_NAME/$FILE_NAME"
echo ""
echo "=============== SCRIPT FINISHED =============="
