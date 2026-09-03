# DevOps Homework

**Kunal Kumar · Roll No. 24BCS10027**

Linux, shell scripting, networking, Git and Docker homework from the
[devops-heros](https://github.com/MineshShaw/devops-heros) sessions — one folder per
topic.

Every command in this repository was **actually executed** on a real Ubuntu 26.04
machine as user `kunal`. The `console` blocks are captured terminal output and the
screenshots are of those live sessions — nothing is written by hand or mocked up.

---

## Contents

| # | Folder | Assignment | Evidence |
|---|---|---|---|
| 1 | [`01-linux-basics/`](01-linux-basics/) | Soft/hard links · `adduser` vs `useradd` · `journalctl` · command cheat sheet | 6 terminal screenshots + full output |
| 2 | [`02-shell-scripting/`](02-shell-scripting/) | System information script | screenshot, transcript, and the files the script generated |
| 3 | [`03-networking/`](03-networking/) | IP addressing & subnetting, networking commands with explanations | 37 commands with output + notes, 1 screenshot |
| 4 | [`04-git/`](04-git/) | `git commit -a -m` vs `git commit -m` · cherry-pick | 2 screenshots + two full git sessions |
| 5 | [`05-docker-hello-world/`](05-docker-hello-world/) | Six Hello World apps, each with a Dockerfile | 6 browser screenshots + 1 terminal + build logs |
| 6 | [`06-docker-multistage/`](06-docker-multistage/) | Multi-stage build on port 8080 + 3 deployed apps | [submission.md](06-docker-multistage/submission.md), 2 screenshots |
| 7 | [`07-docker-networking-volumes/`](07-docker-networking-volumes/) | Container networking · host network · bind mount · overlay network | 5 screenshots + full logs |
| — | [`logs/`](logs/) | the raw, unedited session logs everything above is quoted from | 12 files |

**24 screenshots** in total.

---

## Highlights

**Linux** — the hard link and the original share inode `525715` with a link count of 2;
delete the original and the hard link still works while the symlink dangles. `adduser`
created `testuser` with a home directory, bash shell and a working password, captured as
a real interactive session; bare `useradd` left a locked account with no home.
`journalctl -u cron` shows a live `systemctl restart` appearing in the journal.

**Shell scripting** — [`system_info.sh`](02-shell-scripting/system_info.sh) uses 12
variables, four `read -p` prompts (name, roll number, comment, directory), `mkdir`,
`touch` and `>` redirection, and wrote 227 lines of `ps aux` into the file it created.

**Networking** — IP classes, subnet masks and private ranges applied to this machine's
own `192.168.5.15/24`, then `ip`, `ping`, `traceroute`, `dig`, `ss`, `curl`, `nc`,
`nmap` and `tcpdump` each with output and an explanation of how to read it.

**Git** — `git commit -m` refused with *"no changes added to commit"* while
`git commit -a -m` committed a modified **and** a deleted tracked file, and still ignored
the new untracked one. A commit was cherry-picked from `feature` (`988b4de`) onto `main`
(`283c949`) — same change, new hash, and the unrelated feature file stayed behind.

**Docker** — six apps built and verified in a browser. The class multi-stage Dockerfile
was cloned, built and run on **port 8080** showing *Hello World from Docker Multi-Stage
Build!*. Three networks with a dual-homed backend proved real isolation:
`frontend → database` fails with `bad address`. A bind-mounted file edited on the host
appeared instantly in the container with no restart, and a read-only mount rejected a
write from inside. A real overlay network was created on a swarm and a 2-replica service
resolved by name across it.

---

## Environment

The work was done on a Mac with no native Linux or Docker, so a real Ubuntu VM was set
up rather than faking any output:

```bash
brew install lima
limactl start --name=devops --cpus 4 --memory 8 \
  --set '.user.name="kunal"' template://ubuntu-lts
limactl shell devops

sudo hostnamectl set-hostname kunal-devops
sudo apt install -y docker.io git ttyd expect net-tools dnsutils traceroute \
                    curl wget netcat-openbsd telnet whois tcpdump nmap
```

* Ubuntu **26.04 LTS**, systemd **259**, aarch64
* Docker Engine **29.1.3**
* Everything runs as user **`kunal`** on host **`kunal-devops`**

### How the screenshots were taken

* **Web pages** — the containers publish their ports out of the VM, so each page was
  opened in a real browser on the host and captured.
* **Terminal sessions** — `ttyd` serves a real terminal attached to a live `bash`
  process in the VM; each session was run in it and the terminal captured. They are
  screenshots of actual runs, not renderings of a log file. The same runs are also
  committed as text in [`logs/`](logs/).

---

## Notes

* Where a host port was already in use, the app was published on a free port instead —
  the container ports are the conventional ones. Each README says which.
* The `traceroute` output has its first three hops (this connection's own last-mile
  routers) redacted, and the `ifconfig.me` public IP is not included, since this
  repository is public.
