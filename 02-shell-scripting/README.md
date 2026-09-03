# Shell Scripting Homework — System Information Script

A single script, [`system_info.sh`](system_info.sh), that prints the date, hostname,
username, disk usage and running processes, asks the user for a directory name, creates
that directory and a file inside it, and saves the process list into the file with `>`.

## Folder contents

```
02-shell-scripting/
├── README.md                            this file, with the full output
├── system_info.sh                       the script
└── output/
    ├── script-output.txt                the complete terminal transcript
    └── system_report/
        └── processes.txt                the file the script actually created
```

## Requirements checklist

| Requirement | Where it happens in the script |
|---|---|
| Prints the current date | `CURRENT_DATE=$(date)` → `echo "Current Date : $CURRENT_DATE"` |
| Prints the hostname | `HOST_NAME=$(hostname)` |
| Prints the username | `USER_NAME=$(whoami)` |
| Prints the disk usage | `DISK_USAGE=$(df -h)` |
| Prints the running processes | `PROCESS_LIST=$(ps aux)` |
| Uses variables | 7 variables: `CURRENT_DATE`, `HOST_NAME`, `USER_NAME`, `DISK_USAGE`, `PROCESS_LIST`, `DIR_NAME`, `FILE_NAME` |
| Takes user input with `read -p` | `read -p "Enter a name for the report directory: " DIR_NAME` |
| Creates a directory with `mkdir` | `mkdir -p "$DIR_NAME"` |
| Creates a file with `touch` | `touch "$DIR_NAME/$FILE_NAME"` |
| Stores processes with `>` | `ps aux > "$DIR_NAME/$FILE_NAME"` |
| `echo` | used throughout for all the printing |

## How to run it

```bash
chmod +x system_info.sh
./system_info.sh                    # interactive — it asks for the directory name

# or non-interactively:
echo "system_report" | ./system_info.sh
```

## The script

```bash
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
```

## Output — the complete run

Run on Ubuntu 26.04. The value supplied at the `read -p` prompt was **`system_report`**.
Because the answer was piped in so the whole session could be captured, it does not
appear echoed after the prompt — the line reads
`Enter a name for the report directory: Directory created: system_report`, where
everything after the colon is the script's next line of output. Typed by hand, the
word `system_report` would appear right after the prompt.

```console
$ chmod +x system_info.sh
$ ./system_info.sh
system_report
==============================================
           SYSTEM INFORMATION REPORT          
==============================================

Current Date : Thu Sep  3 20:54:02 IST 2026
Hostname     : lima-linuxlab
Username     : kunalpronto

----------------- DISK USAGE -----------------
Filesystem             Size  Used Avail Use% Mounted on
tmpfs                  780M 1020K  779M   1% /run
/dev/vda1               96G  3.1G   93G   4% /
tmpfs                  2.0G     0  2.0G   0% /dev/shm
efivarfs                56K  1.4K   55K   3% /sys/firmware/efi/efivars
tmpfs                  2.0G     0  2.0G   0% /tmp
none                   1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
/dev/vda13             891M  126M  704M  16% /boot
/dev/vda15              98M  6.5M   91M   7% /boot/efi
none                   1.0M     0  1.0M   0% /run/credentials/systemd-networkd.service
lima-91dda870eb627210  927G  263G  664G  29% /Users/kunalpronto
/dev/vdb               269M  269M     0 100% /mnt/lima-cidata
none                   1.0M     0  1.0M   0% /run/credentials/systemd-resolved.service
tmpfs                  390M   40K  390M   1% /run/user/501
none                   1.0M     0  1.0M   0% /run/credentials/sshd@4-3-3:22-2:2914939157.service
none                   1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
none                   1.0M     0  1.0M   0% /run/credentials/serial-getty@hvc0.service

-------- RUNNING PROCESSES (top 10) ----------
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.3  0.4  26748 17240 ?        Ss   20:47   0:01 /usr/lib/systemd/systemd --switched-root --system --deserialize=44
root           2  0.0  0.0      0     0 ?        S    20:47   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    20:47   0:00 [pool_workqueue_release]
root           4  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-rcu_gp]
root           5  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-sync_wq]
root           6  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-kvfree_rcu_reclaim]
root           7  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-slub_flushwq]
root           8  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-netns]
root          10  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/0:0H-kblockd]

Enter a name for the report directory: Directory created: system_report
File created    : system_report/processes.txt

Running processes saved to system_report/processes.txt
Lines written: 123

First 5 lines of the saved file:
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.3  0.4  26748 17240 ?        Ss   20:47   0:01 /usr/lib/systemd/systemd --switched-root --system --deserialize=44
root           2  0.0  0.0      0     0 ?        S    20:47   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    20:47   0:00 [pool_workqueue_release]
root           4  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-rcu_gp]

=============== SCRIPT FINISHED ==============
```

## The directory and file the script created

```console
$ ls -la
total 16
drwxrwxr-x 3 kunalpronto kunalpronto 4096 Sep  3 20:54 .
drwxr-x--- 9 kunalpronto kunalpronto 4096 Sep  3 20:53 ..
-rwxrwxr-x 1 kunalpronto kunalpronto 2596 Sep  3 20:53 system_info.sh
drwxrwxr-x 2 kunalpronto kunalpronto 4096 Sep  3 20:54 system_report

$ ls -la system_report/
total 24
drwxrwxr-x 2 kunalpronto kunalpronto  4096 Sep  3 20:54 .
drwxrwxr-x 3 kunalpronto kunalpronto  4096 Sep  3 20:54 ..
-rw-rw-r-- 1 kunalpronto kunalpronto 12733 Sep  3 20:54 processes.txt

$ wc -l system_report/processes.txt
123 system_report/processes.txt
```

The generated file is committed at
[`output/system_report/processes.txt`](output/system_report/processes.txt) — first few
lines:

```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.3  0.4  26748 17240 ?        Ss   20:47   0:01 /usr/lib/systemd/systemd --switched-root --system --deserialize=44
root           2  0.0  0.0      0     0 ?        S    20:47   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    20:47   0:00 [pool_workqueue_release]
root           4  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-rcu_gp]
root           5  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-sync_wq]
root           6  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-kvfree_rcu_reclaim]
root           7  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-slub_flushwq]
```

## Notes on the commands used

| Command | What it does here |
|---|---|
| `date` | current date and time |
| `hostname` | the machine's name |
| `whoami` | the user running the script |
| `df -h` | disk usage per filesystem, human-readable (`-h`) |
| `ps aux` | every running process, with user, PID, CPU%, memory% and command |
| `read -p "prompt " VAR` | prints the prompt and reads one line of input into `VAR` |
| `mkdir -p` | creates the directory; `-p` means "no error if it already exists" |
| `touch` | creates an empty file (or updates its timestamp if it exists) |
| `>` | **overwrites** the file with the command's output |
| `>>` | **appends** instead (used nowhere here, but worth knowing) |
| `$(command)` | command substitution — runs the command and stores its output |
| `"$VAR"` | always quote variables so spaces don't split them into separate words |

The script also guards against an empty answer: if you just press Enter, `DIR_NAME`
falls back to `system_report` instead of trying to `mkdir ""`.
