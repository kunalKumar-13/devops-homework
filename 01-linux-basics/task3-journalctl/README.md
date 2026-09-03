# Task 3 — `journalctl`

Run on **Ubuntu 26.04 LTS** with **systemd 259**. All output is real.

---

## 1. What is `journalctl` used for?

`journalctl` is the tool for reading the **systemd journal** — the single, structured,
indexed log that `systemd-journald` collects on every modern Linux system.

Everything lands in one place:

* kernel messages (what `dmesg` shows)
* early boot and initrd messages
* stdout/stderr of every service systemd starts
* anything written to syslog
* audit records and login/`sudo` events

Why it replaced tailing `/var/log/*`:

| Old way | journald |
|---|---|
| plain text files, one per program | one binary, **indexed** store |
| filtering with `grep` | native filters: by unit, boot, priority, time, PID, user |
| no structure | key/value **structured fields** (`-o json`) |
| easy to forge / lose ordering | append-only, sequence-numbered, can be sealed |
| rotation via `logrotate` | built-in size/time limits and `--vacuum-*` |

Storage lives in `/var/log/journal/<machine-id>/` when persistent, or
`/run/log/journal/` when volatile (wiped on reboot).

---

## 2. The commands worth knowing

```bash
# --- basics ---
journalctl                     # everything, oldest first, in a pager
journalctl -n 50               # last 50 lines
journalctl -f                  # live follow, like tail -f
journalctl -r                  # newest first
journalctl --no-pager          # print straight to stdout (scripts)

# --- per service (the one you use daily) ---
journalctl -u ssh              # all logs for the ssh unit
journalctl -u nginx -n 100     # last 100 lines for nginx
journalctl -u nginx -f         # follow one service live
journalctl -u nginx --since today
systemctl status nginx         # shows the last ~10 journal lines inline

# --- per boot ---
journalctl -b                  # current boot only
journalctl -b -1               # the PREVIOUS boot (why did it crash?)
journalctl --list-boots        # every boot the journal still has

# --- priority (syslog levels 0..7) ---
journalctl -p err              # err and worse (err, crit, alert, emerg)
journalctl -p warning -b
journalctl -p 3 -xb            # classic "show me today's errors"

# --- time windows ---
journalctl --since "2026-09-03 10:00:00" --until "2026-09-03 11:00:00"
journalctl --since "1 hour ago"
journalctl --since yesterday

# --- other filters ---
journalctl -k                          # kernel messages only (= dmesg)
journalctl _PID=1234                   # by process id
journalctl /usr/sbin/sshd              # by executable
journalctl _UID=1000                   # by user
journalctl --user -u myapp.service     # a user unit
journalctl -u ssh -g "Failed password" # grep inside the journal

# --- output formats ---
journalctl -u ssh -o json-pretty       # full structured record
journalctl -o short-precise            # microsecond timestamps
journalctl -o cat                      # message text only

# --- housekeeping ---
journalctl --disk-usage
sudo journalctl --vacuum-time=30d      # drop entries older than 30 days
sudo journalctl --vacuum-size=200M     # cap the journal at 200 MB
journalctl --verify                    # integrity check
```

Useful combination for debugging a failing service:

```bash
sudo systemctl status myapp        # is it running? what was the exit code?
sudo journalctl -u myapp -n 100 --no-pager   # what did it print before dying?
sudo journalctl -u myapp -f                  # watch while you restart it
```

---

## 3. Practical session (real output)

```console
########## 0. Environment ##########
$ hostnamectl 2>/dev/null | head -n 6
 Static hostname: lima-linuxlab
       Icon name: computer-vm
         Chassis: vm 🖴
      Machine ID: 3c46d72da4ae4ce6af05c36da2aa9943
         Boot ID: f3cc6d1c8ce142a7ad28ddd5817573f9
    AF_VSOCK CID: 3

$ systemctl --version | head -n 1
systemd 259 (259.5-0ubuntu3)


########## 1. What journalctl reads ##########
$ sudo journalctl --disk-usage
Archived and active journals take up 8M in the file system.

$ ls -la /var/log/journal 2>/dev/null || echo '(volatile journal in /run/log/journal)'
total 12
drwxr-sr-x+ 3 root systemd-journal 4096 Sep  3 20:47 .
drwxrwxr-x 10 root syslog          4096 Sep  3 20:47 ..
drwxr-sr-x+ 2 root systemd-journal 4096 Sep  3 20:47 3c46d72da4ae4ce6af05c36da2aa9943


########## 2. The most recent log lines ##########
$ sudo journalctl -n 15 --no-pager
Sep 03 20:52:09 lima-linuxlab sudo[10299]: pam_unix(sudo:session): session opened for user root(uid=0) by kunalpronto(uid=501)
Sep 03 20:52:09 lima-linuxlab sudo[10299]: kunalpronto :  PWD=/Users/kunalpronto ; USER=root ; COMMAND=/usr/sbin/userdel -r testuser_low
Sep 03 20:52:09 lima-linuxlab userdel[10302]: delete user 'testuser_low'
Sep 03 20:52:09 lima-linuxlab userdel[10302]: removed group 'testuser_low' owned by 'testuser_low'
Sep 03 20:52:09 lima-linuxlab userdel[10302]: removed shadow group 'testuser_low' owned by 'testuser_low'
Sep 03 20:52:09 lima-linuxlab sudo[10299]: pam_unix(sudo:session): session closed for user root
Sep 03 20:52:09 lima-linuxlab dbus-daemon[1453]: [system] Activating via systemd: service name='org.freedesktop.hostname1' unit='dbus-org.freedesktop.hostname1.service' requested by ':1.27' (uid=501 pid=10323 comm="hostnamectl" label="unconfined")
Sep 03 20:52:09 lima-linuxlab systemd[1]: Starting systemd-hostnamed.service - Hostname Service...
Sep 03 20:52:09 lima-linuxlab systemd[1]: Started systemd-hostnamed.service - Hostname Service.
Sep 03 20:52:09 lima-linuxlab dbus-daemon[1453]: [system] Successfully activated service 'org.freedesktop.hostname1'
Sep 03 20:52:09 lima-linuxlab sudo[10330]: pam_unix(sudo:session): session opened for user root(uid=0) by kunalpronto(uid=501)
Sep 03 20:52:09 lima-linuxlab sudo[10330]: kunalpronto :  PWD=/Users/kunalpronto ; USER=root ; COMMAND=/usr/bin/journalctl --disk-usage
Sep 03 20:52:09 lima-linuxlab sudo[10330]: pam_unix(sudo:session): session closed for user root
Sep 03 20:52:09 lima-linuxlab sudo[10334]: pam_unix(sudo:session): session opened for user root(uid=0) by kunalpronto(uid=501)
Sep 03 20:52:09 lima-linuxlab sudo[10334]: kunalpronto :  PWD=/Users/kunalpronto ; USER=root ; COMMAND=/usr/bin/journalctl -n 15 --no-pager


########## 3. Logs since this boot ##########
$ sudo journalctl -b --no-pager | head -n 15
Sep 03 20:47:46 localhost kernel: Booting Linux on physical CPU 0x0000000000 [0x610f0000]
Sep 03 20:47:46 localhost kernel: Linux version 7.0.0-28-generic (buildd@bos03-arm64-120) (aarch64-linux-gnu-gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0, GNU ld (GNU Binutils for Ubuntu) 2.46) #28-Ubuntu SMP PREEMPT_DYNAMIC Sun Jun 21 00:50:10 UTC 2026 (Ubuntu 7.0.0-28.28-generic 7.0.12)
Sep 03 20:47:46 localhost kernel: KASLR enabled
Sep 03 20:47:46 localhost kernel: efi: EFI v2.7 by EDK II
Sep 03 20:47:46 localhost kernel: efi: ACPI 2.0=0x16fbf0018 SMBIOS=0xfffff000 SMBIOS 3.0=0x16fc1a000 MOKvar=0x16e320000 INITRD=0x16e44db18 RNG=0x16fbff818 MEMRESERVE=0x16e44d898 
Sep 03 20:47:46 localhost kernel: random: crng init done
Sep 03 20:47:46 localhost kernel: secureboot: Secure boot disabled
Sep 03 20:47:46 localhost kernel: ACPI: Early table checksum verification disabled
Sep 03 20:47:46 localhost kernel: ACPI: RSDP 0x000000016FBF0018 000024 (v02 APPLE )
Sep 03 20:47:46 localhost kernel: ACPI: XSDT 0x000000016FBFFE98 000044 (v01 APPLE  Apple Vz 00000001      01000013)
Sep 03 20:47:46 localhost kernel: ACPI: FACP 0x000000016FBFFA98 000114 (v06 APPLE  Apple Vz 00000001 AAPL 20180427)
Sep 03 20:47:46 localhost kernel: ACPI: DSDT 0x000000016FBFE998 00035A (v02 APPLE  Apple Vz 00000001 AAPL 20180427)
Sep 03 20:47:46 localhost kernel: ACPI: GTDT 0x000000016FBFFC18 000068 (v03 APPLE  Apple Vz 00000001 AAPL 20180427)
Sep 03 20:47:46 localhost kernel: ACPI: APIC 0x000000016FBFFD18 00010C (v05 APPLE  Apple Vz 00000001 AAPL 20180427)
Sep 03 20:47:46 localhost kernel: ACPI: MCFG 0x000000016FBFFF98 00003C (v01 APPLE  Apple Vz 00000001 AAPL 20180427)

$ sudo journalctl --list-boots --no-pager
IDX BOOT ID                          FIRST ENTRY                 LAST ENTRY
  0 f3cc6d1c8ce142a7ad28ddd5817573f9 Thu 2026-09-03 20:47:46 IST Thu 2026-09-03 20:52:09 IST


########## 4. Logs for ONE service (ssh) ##########
$ systemctl status ssh --no-pager | head -n 12
● ssh.service - OpenBSD Secure Shell server
     Loaded: loaded (/usr/lib/systemd/system/ssh.service; disabled; preset: enabled)
     Active: active (running) since Thu 2026-09-03 20:47:54 IST; 4min 15s ago
 Invocation: 84d1b7dd5469443bacc775420eb2f164
TriggeredBy: ● ssh.socket
       Docs: man:sshd(8)
             man:sshd_config(5)
   Main PID: 1921 (sshd)
      Tasks: 1 (limit: 4107)
     Memory: 1.2M (peak: 3.2M)
        CPU: 29ms
     CGroup: /system.slice/ssh.service

$ sudo journalctl -u ssh --no-pager -n 15
Sep 03 20:47:54 lima-linuxlab systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Sep 03 20:47:54 lima-linuxlab sshd[1921]: Server listening on 0.0.0.0 port 22.
Sep 03 20:47:54 lima-linuxlab sshd[1921]: Server listening on :: port 22.
Sep 03 20:47:54 lima-linuxlab systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
Sep 03 20:47:54 lima-linuxlab sshd-session[1924]: Connection closed by 192.168.5.2 port 60249
Sep 03 20:47:54 lima-linuxlab systemd[1]: Reloading ssh.service - OpenBSD Secure Shell server...
Sep 03 20:47:54 lima-linuxlab sshd[1921]: Received SIGHUP; restarting.
Sep 03 20:47:54 lima-linuxlab systemd[1]: Reloaded ssh.service - OpenBSD Secure Shell server.
Sep 03 20:47:54 lima-linuxlab sshd[1921]: Server listening on 0.0.0.0 port 22.
Sep 03 20:47:54 lima-linuxlab sshd[1921]: Server listening on :: port 22.


########## 5. Restart a service and watch its new log entries ##########
$ sudo systemctl restart cron

$ sudo journalctl -u cron --no-pager -n 10
Sep 03 20:47:52 lima-linuxlab systemd[1]: Started cron.service - Regular background program processing daemon.
Sep 03 20:47:52 lima-linuxlab (cron)[1452]: cron.service: Referenced but unset environment variable evaluates to an empty string: EXTRA_OPTS
Sep 03 20:47:52 lima-linuxlab cron[1452]: (CRON) INFO (pidfile fd = 3)
Sep 03 20:47:52 lima-linuxlab cron[1452]: (CRON) INFO (Running @reboot jobs)
Sep 03 20:52:09 lima-linuxlab systemd[1]: Stopping cron.service - Regular background program processing daemon...
Sep 03 20:52:09 lima-linuxlab systemd[1]: cron.service: Deactivated successfully.
Sep 03 20:52:09 lima-linuxlab systemd[1]: Stopped cron.service - Regular background program processing daemon.
Sep 03 20:52:09 lima-linuxlab systemd[1]: Started cron.service - Regular background program processing daemon.
Sep 03 20:52:09 lima-linuxlab (cron)[10353]: cron.service: Referenced but unset environment variable evaluates to an empty string: EXTRA_OPTS
Sep 03 20:52:09 lima-linuxlab cron[10353]: (CRON) INFO (pidfile fd = 3)


########## 6. Filter by priority (errors and worse) ##########
$ sudo journalctl -p err -b --no-pager | tail -n 15
Sep 03 20:47:46 localhost kernel: PCI: OF: of_root node is NULL, cannot create PCI host bridge node
Sep 03 20:47:56 lima-linuxlab chronyd[1549]: Could not receive NTS-KE message from 91.189.91.113:4460 (4.ntp.ubuntu.com) : The TLS connection was non-properly terminated.
Sep 03 20:48:01 lima-linuxlab chronyd[1549]: TLS handshake with 91.189.91.112:4460 (3.ntp.ubuntu.com) failed : The TLS connection was non-properly terminated.


########## 7. Filter by time ##########
$ sudo journalctl --since '10 minutes ago' --no-pager | tail -n 10
Sep 03 20:52:09 lima-linuxlab sudo[10354]: kunalpronto :  PWD=/Users/kunalpronto ; USER=root ; COMMAND=/usr/bin/journalctl -u cron --no-pager -n 10
Sep 03 20:52:09 lima-linuxlab (cron)[10353]: cron.service: Referenced but unset environment variable evaluates to an empty string: EXTRA_OPTS
Sep 03 20:52:09 lima-linuxlab cron[10353]: (CRON) INFO (pidfile fd = 3)
Sep 03 20:52:09 lima-linuxlab cron[10353]: (CRON) INFO (Skipping @reboot jobs -- not system startup)
Sep 03 20:52:09 lima-linuxlab sudo[10354]: pam_unix(sudo:session): session closed for user root
Sep 03 20:52:09 lima-linuxlab sudo[10357]: pam_unix(sudo:session): session opened for user root(uid=0) by kunalpronto(uid=501)
Sep 03 20:52:09 lima-linuxlab sudo[10357]: kunalpronto :  PWD=/Users/kunalpronto ; USER=root ; COMMAND=/usr/bin/journalctl -p err -b --no-pager
Sep 03 20:52:09 lima-linuxlab sudo[10357]: pam_unix(sudo:session): session closed for user root
Sep 03 20:52:09 lima-linuxlab sudo[10361]: pam_unix(sudo:session): session opened for user root(uid=0) by kunalpronto(uid=501)
Sep 03 20:52:09 lima-linuxlab sudo[10361]: kunalpronto :  PWD=/Users/kunalpronto ; USER=root ; COMMAND=/usr/bin/journalctl --since 10 minutes ago --no-pager


########## 8. Kernel messages only ##########
$ sudo journalctl -k --no-pager | head -n 10
Sep 03 20:47:46 localhost kernel: Booting Linux on physical CPU 0x0000000000 [0x610f0000]
Sep 03 20:47:46 localhost kernel: Linux version 7.0.0-28-generic (buildd@bos03-arm64-120) (aarch64-linux-gnu-gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0, GNU ld (GNU Binutils for Ubuntu) 2.46) #28-Ubuntu SMP PREEMPT_DYNAMIC Sun Jun 21 00:50:10 UTC 2026 (Ubuntu 7.0.0-28.28-generic 7.0.12)
Sep 03 20:47:46 localhost kernel: KASLR enabled
Sep 03 20:47:46 localhost kernel: efi: EFI v2.7 by EDK II
Sep 03 20:47:46 localhost kernel: efi: ACPI 2.0=0x16fbf0018 SMBIOS=0xfffff000 SMBIOS 3.0=0x16fc1a000 MOKvar=0x16e320000 INITRD=0x16e44db18 RNG=0x16fbff818 MEMRESERVE=0x16e44d898 
Sep 03 20:47:46 localhost kernel: random: crng init done
Sep 03 20:47:46 localhost kernel: secureboot: Secure boot disabled
Sep 03 20:47:46 localhost kernel: ACPI: Early table checksum verification disabled
Sep 03 20:47:46 localhost kernel: ACPI: RSDP 0x000000016FBF0018 000024 (v02 APPLE )
Sep 03 20:47:46 localhost kernel: ACPI: XSDT 0x000000016FBFFE98 000044 (v01 APPLE  Apple Vz 00000001      01000013)


########## 9. Other useful forms ##########
$ sudo journalctl -u ssh -o json-pretty --no-pager -n 1
{
	"MESSAGE" : "Server listening on :: port 22.",
	"__REALTIME_TIMESTAMP" : "1788448674862232",
	"_BOOT_ID" : "f3cc6d1c8ce142a7ad28ddd5817573f9",
	"_EXE" : "/usr/sbin/sshd",
	"_COMM" : "sshd",
	"_SYSTEMD_UNIT" : "ssh.service",
	"SYSLOG_TIMESTAMP" : "Sep  3 20:47:54 ",
	"SYSLOG_FACILITY" : "4",
	"_RUNTIME_SCOPE" : "system",
	"SYSLOG_PID" : "1921",
	"__SEQNUM_ID" : "e5d9dca03ee04e38ac0fde30531e58d7",
	"_TRANSPORT" : "syslog",
	"_SYSTEMD_INVOCATION_ID" : "84d1b7dd5469443bacc775420eb2f164",
	"PRIORITY" : "6",
	"_CAP_EFFECTIVE" : "1ffffffffff",
	"_CMDLINE" : "/usr/sbin/sshd -D",
	"_GID" : "0",
	"_MACHINE_ID" : "3c46d72da4ae4ce6af05c36da2aa9943",
	"__SEQNUM" : "1388",
	"_PID" : "1921",
	"_SOURCE_REALTIME_TIMESTAMP" : "1788448674862231",
	"_HOSTNAME" : "lima-linuxlab",
	"_SYSTEMD_SLICE" : "system.slice",
	"__CURSOR" : "s=e5d9dca03ee04e38ac0fde30531e58d7;i=56c;b=f3cc6d1c8ce142a7ad28ddd5817573f9;m=808bb8;t=65a95a7f6d498;x=5558cf7a81f572e6",
	"__MONOTONIC_TIMESTAMP" : "8424376",
	"_UID" : "0",
	"_SYSTEMD_CGROUP" : "/system.slice/ssh.service",
	"SYSLOG_IDENTIFIER" : "sshd"
}

$ sudo journalctl -u cron --since today --no-pager | wc -l
11

Live follow (does not terminate, so not captured here):  sudo journalctl -f -u ssh

########## 10. Housekeeping ##########
$ sudo journalctl --vacuum-time=30d 2>&1 | tail -n 3
Vacuuming done, freed 0B of archived journals from /var/log/journal/3c46d72da4ae4ce6af05c36da2aa9943.
Vacuuming done, freed 0B of archived journals from /run/log/journal.
Vacuuming done, freed 0B of archived journals from /var/log/journal.

```

---

## 4. Checking the logs of a specific service — the key part

```bash
sudo systemctl restart cron
sudo journalctl -u cron --no-pager -n 10
```

The restart appears in the journal immediately, with `systemd` logging the stop and
start of the unit around the service's own messages. Same pattern works for any unit:
`ssh`, `nginx`, `docker`, `mysql`, or your own `myapp.service`.

---

## 5. Interview answers

**Q. What is journalctl?**
The query tool for the systemd journal — a structured, indexed binary log collected by
`systemd-journald` covering the kernel, boot, every systemd unit and syslog.

**Q. How do you see the logs of one service?**
`journalctl -u <unit>`, optionally with `-n 100` for the tail, `-f` to follow, or
`--since "1 hour ago"`.

**Q. A server rebooted unexpectedly — where do you look?**
`journalctl -b -1 -p err` — the previous boot, errors and worse. `journalctl --list-boots`
shows which boots are still stored.

**Q. Journal logs disappear after reboot. Why?**
`/var/log/journal` does not exist, so journald is running in volatile mode in `/run`.
Fix: `sudo mkdir -p /var/log/journal && sudo systemctl restart systemd-journald`, or set
`Storage=persistent` in `/etc/systemd/journald.conf`.

**Q. The journal is filling the disk.**
`journalctl --disk-usage` to confirm, then `sudo journalctl --vacuum-size=200M` or
`--vacuum-time=7d`, and set `SystemMaxUse=` in `/etc/systemd/journald.conf` so it stays
capped.

**Q. journalctl vs `/var/log/syslog`?**
`syslog` is plain text written by rsyslog; the journal is binary, structured and
indexed, and it captures service stdout/stderr and early boot messages that never reach
syslog. On Ubuntu both can coexist — rsyslog reads from the journal.
