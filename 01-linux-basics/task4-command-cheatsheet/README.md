# Task 4 — Linux Command Cheat Sheet

The cheat sheet below is the reference; the section after it is a **real terminal
session** on Ubuntu 26.04 where every important command was actually run.

---

## 1. The cheat sheet

### Navigation

| Command | Purpose |
|---|---|
| `pwd` | print working directory — where am I |
| `ls` | list files |
| `ls -l` | long listing: permissions, owner, size, date |
| `ls -la` | include hidden (dot) files |
| `ls -lh` | human-readable sizes |
| `cd /path` | change directory |
| `cd ~` / `cd` | go home |
| `cd ..` | up one level |
| `cd -` | back to the previous directory |

### Files and directories

| Command | Purpose |
|---|---|
| `mkdir dir` | create a directory |
| `mkdir -p a/b/c` | create the whole nested path |
| `touch file` | create an empty file / update its timestamp |
| `cp src dst` | copy a file |
| `cp -r srcdir dstdir` | copy a directory tree |
| `mv src dst` | move **or rename** |
| `rm file` | delete a file |
| `rm -r dir` | delete a directory tree |
| `rm -rf dir` | force, no prompts — **dangerous** |
| `rmdir dir` | remove an *empty* directory |
| `tree` | show the directory tree |

### Viewing files

| Command | Purpose |
|---|---|
| `cat file` | print the whole file |
| `less file` | scroll through a file (`q` quits) |
| `head -n 20 file` | first 20 lines |
| `tail -n 20 file` | last 20 lines |
| `tail -f logfile` | follow a growing file live |
| `wc -l file` | count lines (`-w` words, `-c` bytes) |

### Searching

| Command | Purpose |
|---|---|
| `grep "text" file` | find lines containing text |
| `grep -i` | case-insensitive |
| `grep -n` | show line numbers |
| `grep -r "text" dir/` | search recursively |
| `grep -v "text"` | invert — lines that do **not** match |
| `grep -c "text"` | count matching lines |
| `find . -name "*.log"` | find by name |
| `find / -type d -name conf` | find directories |
| `find . -size +10M` | find by size |
| `find . -mtime -1` | modified in the last day |
| `which cmd` / `type cmd` | where a command lives |

### Redirection and pipes

| Command | Purpose |
|---|---|
| `cmd > file` | send stdout to a file (**overwrite**) |
| `cmd >> file` | append to a file |
| `cmd 2> file` | redirect stderr |
| `cmd > file 2>&1` | both stdout and stderr |
| `cmd < file` | read stdin from a file |
| `cmd1 \| cmd2` | pipe cmd1's output into cmd2 |
| `cmd \| tee file` | show on screen **and** save |

### Permissions and ownership

| Command | Purpose |
|---|---|
| `chmod +x script.sh` | make executable |
| `chmod 755 file` | rwx for owner, rx for group/others |
| `chmod 644 file` | rw for owner, r for the rest |
| `chown user:group file` | change owner |
| `umask` | default permission mask |
| `id` / `whoami` | who am I, which groups |
| `sudo cmd` | run as root |
| `su - user` | switch user |

Numeric permissions: `r=4  w=2  x=1` — so `7 = rwx`, `6 = rw-`, `5 = r-x`, `4 = r--`.

### Processes

| Command | Purpose |
|---|---|
| `ps aux` | every process (BSD style) |
| `ps -ef` | every process (System V style) |
| `top` / `htop` | live process monitor |
| `pgrep -a name` | find PIDs by name |
| `kill PID` | ask a process to stop (SIGTERM) |
| `kill -9 PID` | force kill (SIGKILL) |
| `pkill name` | kill by name |
| `cmd &` | run in the background |
| `jobs` / `fg` / `bg` | manage background jobs |
| `nohup cmd &` | keep running after logout |

### Disk and memory

| Command | Purpose |
|---|---|
| `df -h` | free space per filesystem |
| `du -sh dir` | size of a directory |
| `du -sh * \| sort -h` | what is eating the disk |
| `free -h` | RAM and swap |
| `uptime` | uptime and load average |
| `lsblk` | block devices |
| `mount` / `umount` | mount filesystems |

### System information

| Command | Purpose |
|---|---|
| `uname -a` | kernel and architecture |
| `hostname` | machine name |
| `cat /etc/os-release` | distribution and version |
| `date` | current date and time |
| `who` / `w` | who is logged in |
| `history` | previous commands |
| `systemctl status svc` | service state |
| `journalctl -u svc` | service logs |

### Archives and transfers

| Command | Purpose |
|---|---|
| `tar -czf a.tar.gz dir/` | create a gzipped archive |
| `tar -xzf a.tar.gz` | extract |
| `tar -tzf a.tar.gz` | list contents without extracting |
| `zip -r a.zip dir/` / `unzip a.zip` | zip archives |
| `scp file user@host:/path` | copy over SSH |
| `rsync -av src/ dst/` | efficient sync |

### Getting help

`man cmd` · `cmd --help` · `whatis cmd` · `apropos keyword` · `type cmd`

---

## 2. Practice session — every command actually run

```console
############ NAVIGATION ############
$ pwd
/home/kunalpronto.guest/cheatlab

$ cd ~/cheatlab && pwd
/home/kunalpronto.guest/cheatlab

$ ls

$ ls -la /etc | head -n 6
total 944
drwxr-xr-x 108 root root       4096 Sep  3 20:52 .
drwxr-xr-x  20 root root       4096 Sep  3 20:47 ..
-rw-------   1 root root          0 Jul 20 22:03 .pwd.lock
-rw-r--r--   1 root root        789 Jul 20 22:03 .resolv.conf.systemd-resolved.bak
-rw-r--r--   1 root root        255 Jul 20 22:03 .updated

############ FILES & DIRECTORIES ############
$ mkdir -p project/src project/docs

$ touch project/src/app.py project/docs/readme.txt

$ tree project 2>/dev/null || find project
project
project/src
project/src/app.py
project/docs
project/docs/readme.txt

$ cp project/docs/readme.txt project/docs/readme.bak

$ mv project/docs/readme.bak project/docs/notes.txt

$ ls -l project/docs
total 0
-rw-rw-r-- 1 kunalpronto kunalpronto 0 Sep  3 20:53 notes.txt
-rw-rw-r-- 1 kunalpronto kunalpronto 0 Sep  3 20:53 readme.txt

$ rm project/docs/notes.txt

$ rmdir project/docs
rmdir: failed to remove 'project/docs': Directory not empty

$ ls project
docs
src

############ VIEWING FILE CONTENT ############
$ printf 'alpha\nbravo\ncharlie\ndelta\necho\n' > words.txt

$ cat words.txt
alpha
bravo
charlie
delta
echo

$ head -n 2 words.txt
alpha
bravo

$ tail -n 2 words.txt
delta
echo

$ wc -l words.txt
5 words.txt

$ wc -w words.txt
5 words.txt

############ SEARCHING ############
$ grep 'char' words.txt
charlie

$ grep -n -i 'DELTA' words.txt
4:delta

$ grep -c 'a' words.txt
4

$ find ~/cheatlab -name '*.txt'
/home/kunalpronto.guest/cheatlab/words.txt
/home/kunalpronto.guest/cheatlab/project/docs/readme.txt

$ find /etc -maxdepth 1 -name 'host*'
/etc/hosts
/etc/hostname
/etc/host.conf
/etc/hosts.deny
/etc/hosts.allow

############ REDIRECTION & PIPES ############
$ ls -l /etc | head -n 3
total 928
drwxr-xr-x 5 root root       4096 Jul 20 22:06 ModemManager
drwxr-xr-x 2 root root       4096 Jul 20 22:07 PackageKit

$ cat words.txt | sort -r
echo
delta
charlie
bravo
alpha

$ echo 'appended line' >> words.txt && tail -n 2 words.txt
echo
appended line

$ cat words.txt | wc -l
6

############ PERMISSIONS & OWNERSHIP ############
$ touch script.sh && ls -l script.sh
-rw-rw-r-- 1 kunalpronto kunalpronto 0 Sep  3 20:53 script.sh

$ chmod +x script.sh && ls -l script.sh
-rwxrwxr-x 1 kunalpronto kunalpronto 0 Sep  3 20:53 script.sh

$ chmod 640 words.txt && ls -l words.txt
-rw-r----- 1 kunalpronto kunalpronto 45 Sep  3 20:53 words.txt

$ id
uid=501(kunalpronto) gid=1000(kunalpronto) groups=1000(kunalpronto),999(systemd-journal)

$ whoami
kunalpronto

############ PROCESSES ############
$ ps aux | head -n 5
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.3  0.4  26748 17240 ?        Ss   20:47   0:01 /usr/lib/systemd/systemd --switched-root --system --deserialize=44
root           2  0.0  0.0      0     0 ?        S    20:47   0:00 [kthreadd]
root           3  0.0  0.0      0     0 ?        S    20:47   0:00 [pool_workqueue_release]
root           4  0.0  0.0      0     0 ?        I<   20:47   0:00 [kworker/R-rcu_gp]

$ ps -ef | head -n 5
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 20:47 ?        00:00:01 /usr/lib/systemd/systemd --switched-root --system --deserialize=44
root           2       0  0 20:47 ?        00:00:00 [kthreadd]
root           3       2  0 20:47 ?        00:00:00 [pool_workqueue_release]
root           4       2  0 20:47 ?        00:00:00 [kworker/R-rcu_gp]

$ top -b -n 1 | head -n 8
top - 20:53:32 up 5 min,  1 user,  load average: 0.33, 0.10, 0.02
Tasks: 130 total,   1 running, 128 sleeping,   0 stopped,   1 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni, 95.5 id,  4.5 wa,  0.0 hi,  0.0 si,  0.0 st 
MiB Mem :   3895.8 total,   1808.7 free,    493.4 used,   1760.0 buff/cache     
MiB Swap:      0.0 total,      0.0 free,      0.0 used.   3402.3 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      1 root      20   0   26748  17240  10616 S   0.0   0.4   0:01.13 systemd

$ sleep 60 & echo "started background job with PID $!"
started background job with PID 17536

$ jobs
[1]+  Running                    sleep 60 &

$ pgrep -a sleep
17536 sleep 60

$ kill %1 2>/dev/null; sleep 1; pgrep -a sleep || echo '(sleep process killed)'
(sleep process killed)

############ DISK & MEMORY ############
$ df -h
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

$ du -sh ~/cheatlab
20K	/home/kunalpronto.guest/cheatlab

$ free -h
               total        used        free      shared  buff/cache   available
Mem:           3.8Gi       493Mi       1.8Gi       1.0Mi       1.7Gi       3.3Gi
Swap:             0B          0B          0B

$ uptime
 20:53:33 up 5 min,  1 user,  load average: 0.33, 0.10, 0.02

############ SYSTEM INFO ############
$ uname -a
Linux lima-linuxlab 7.0.0-28-generic #28-Ubuntu SMP PREEMPT_DYNAMIC Sun Jun 21 00:50:10 UTC 2026 aarch64 GNU/Linux

$ hostname
lima-linuxlab

$ date
Thu Sep  3 20:53:33 IST 2026

$ cat /etc/os-release | head -n 4
PRETTY_NAME="Ubuntu 26.04 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04 LTS (Resolute Raccoon)"

############ NETWORK (quick look) ############
$ hostname -I
192.168.5.15 

$ ip -brief addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             192.168.5.15/24 metric 200 fe80::5055:55ff:feed:796f/64 

############ ARCHIVES ############
$ tar -czf project.tar.gz project

$ ls -lh project.tar.gz
-rw-rw-r-- 1 kunalpronto kunalpronto 206 Sep  3 20:53 project.tar.gz

$ tar -tzf project.tar.gz
project/
project/src/
project/src/app.py
project/docs/
project/docs/readme.txt

$ mkdir -p restored && tar -xzf project.tar.gz -C restored && find restored
restored
restored/project
restored/project/src
restored/project/src/app.py
restored/project/docs
restored/project/docs/readme.txt

############ HELP ############
$ man ls | head -n 5
LS(1)                       General Commands Manual                       LS(1)

NAME
       ls  -  List  directory  contents.  Ignore files and directories starting
       with a '.' by default

$ ls --help | head -n 5
List directory contents.
Ignore files and directories starting with a '.' by default

Usage: ls [OPTION]... [FILE]...


$ which ls
/usr/bin/ls

$ type cd
cd is a shell builtin

$ history | tail -n 5 || echo '(history is interactive-shell only)'

```

---

## 3. Notes from the practice run

* `mkdir -p project/src project/docs` created two nested trees in one call.
* `mv` was used as a **rename** (`readme.bak` → `notes.txt`) — there is no separate
  rename command.
* `rmdir project/docs` **failed** with `Directory not empty` — `readme.txt` was still
  in there. That is the whole point of `rmdir`: it only removes an *empty* directory,
  which makes it a safe command. To delete a directory that still has contents you
  need `rm -r`, and that is the one to be careful with.
* `chmod +x script.sh` flipped the permissions from `-rw-rw-r--` to `-rwxrwxr-x`, and
  `chmod 640` produced exactly `-rw-r-----`.
* `sleep 60 &` put a job in the background; `jobs` listed it, `pgrep -a sleep` found the
  PID, and `kill %1` stopped it.
* `tar -czf` → `tar -tzf` (list) → `tar -xzf -C restored` (extract elsewhere) is the
  full archive round trip.
* `>` overwrote and `>>` appended — the difference the shell-scripting task depends on.
