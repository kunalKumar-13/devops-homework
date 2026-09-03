# Linux Homework Tasks

All four tasks were carried out on a real **Ubuntu 26.04 LTS (systemd 259, aarch64)**
machine, and every code block marked `console` is copied verbatim from that terminal —
nothing is invented.

| Task | Folder | What it covers |
|---|---|---|
| 1 | [`task1-soft-hard-links/`](task1-soft-hard-links/) | soft links vs hard links, inodes, creating and deleting both, interview answers |
| 2 | [`task2-adduser-vs-useradd/`](task2-adduser-vs-useradd/) | the difference, which Ubuntu prefers and why, a test user created with the recommended command |
| 3 | [`task3-journalctl/`](task3-journalctl/) | what journalctl is for, reading system and per-service logs |
| 4 | [`task4-command-cheatsheet/`](task4-command-cheatsheet/) | the full cheat sheet plus a session where every command is run |

## Quick summary

**Task 1** — a hard link is a second *name* for the same inode; a soft link is a small
file containing a *path*. Delete the original and the hard link keeps working while the
soft link dangles. Hard links cannot cross filesystems or point at directories.

**Task 2** — `useradd` is the low-level binary, `adduser` is the Debian/Ubuntu Perl
wrapper around it. **Ubuntu prefers `adduser`** for interactive use because it creates
the home directory, sets `/bin/bash`, prompts for a password and creates the user's
group. `useradd` is the right choice in scripts and Dockerfiles. Test user `testuser`
was created with `adduser` and verified with `id`, `passwd -S` and an actual login.

**Task 3** — `journalctl` reads the systemd journal: one indexed, structured log for the
kernel, boot and every service. `journalctl -u <service>` is the command used daily.

**Task 4** — the cheat sheet, with every command in it executed and its output captured.

## How the environment was set up

Docker and systemd need Linux, so the work was done in a real Ubuntu VM on the Mac:

```bash
brew install lima
limactl start --name=linuxlab --cpus 2 --memory 4 template://ubuntu-lts
limactl shell linuxlab          # a full Ubuntu shell with systemd, sudo and apt
```
