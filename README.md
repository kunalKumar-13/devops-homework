# DevOps Homework

**Kunal Kumar · Roll No. 24BCS10027**

Linux, shell scripting, networking, Git and Docker homework — one folder per topic.
Every command in this repository was **actually executed**, and the `console` blocks are
real captured output, not written by hand.

---

## Contents

| # | Folder | Assignment | Evidence |
|---|---|---|---|
| 1 | [`01-linux-basics/`](01-linux-basics/) | Soft/hard links · `adduser` vs `useradd` · `journalctl` · command cheat sheet | terminal output from a real Ubuntu 26.04 machine |
| 2 | [`02-shell-scripting/`](02-shell-scripting/) | System information script | the script, its full output, and the file it generated |
| 3 | [`03-networking/`](03-networking/) | Networking commands, output and explanations | 38 commands with output + notes |
| 4 | [`04-git/`](04-git/) | `git commit -a -m` vs `git commit -m` · cherry-pick | two full git sessions with real commit hashes |
| 5 | [`05-docker-hello-world/`](05-docker-hello-world/) | Six Hello World apps, each with a Dockerfile | build logs + browser screenshots of all six |
| 6 | [`06-docker-multistage/`](06-docker-multistage/) | Multi-stage build on port 8080 + 3 deployed apps | build log, `docker ps`, screenshot ([submission](06-docker-multistage/submission.md)) |
| 7 | [`07-docker-networking-volumes/`](07-docker-networking-volumes/) | Container networking · host network · bind mount · overlay network | connectivity tests, before/after screenshots, a live overlay network |

---

## Highlights

**Linux** — hard link and original share inode `524415` with a link count of 2; delete
the original and the hard link still works while the symlink dangles. `adduser` created
`testuser` with a home directory, bash shell and a working password; bare `useradd` left
a locked account with no home. `journalctl -u ssh` and a live `systemctl restart cron`
show per-service logs.

**Shell scripting** — [`system_info.sh`](02-shell-scripting/system_info.sh) uses 7
variables, `read -p`, `mkdir`, `touch` and `>` redirection, and wrote 123 lines of
`ps aux` into the file it created.

**Networking** — `ip`, `ping`, `traceroute`, `dig`, `ss`, `curl`, `nc`, `nmap`,
`tcpdump` and more, each with output and an explanation of how to read it.

**Git** — `git commit -m` refused with *"no changes added to commit"* while
`git commit -a -m` committed the tracked change and still ignored the new file. A
commit was cherry-picked from `feature` (`985d257`) onto `main` (`8f1472c`) — same
change, new hash, and the unrelated feature file stayed behind.

**Docker** — six apps built and verified in a browser. The multi-stage build shrank the
image from **440 MB to 20.2 MB**. Three networks with the backend on two of them proved
real isolation: `frontend → database` fails with `bad address`. A bind-mounted file
changed on the host appeared instantly in the container with no restart. A real overlay
network was created on a swarm and a 2-replica service resolved by name across it.

---

## Environment

The Mac used for this work has no native Linux or Docker, so two real environments were
set up rather than faking any output:

```bash
# A full Ubuntu VM — systemd, sudo, apt (for the Linux and networking tasks)
brew install lima
limactl start --name=linuxlab --cpus 2 --memory 4 template://ubuntu-lts
limactl shell linuxlab

# A real Docker engine (for all the Docker tasks)
brew install colima docker
colima start --cpu 4 --memory 8 --disk 60
docker version
```

* Ubuntu **26.04 LTS**, systemd **259**, aarch64
* Docker Engine **29.5.2** (client 29.7.2), containerd 2.2.4

---

## Notes

* Where a host port was already in use on the machine, the app was published on a free
  port instead — the container ports are the conventional ones. Each README says which.
* Evidence is captured **text output** plus browser screenshots for the web pages. Text
  is searchable, diffable and readable everywhere; screenshots are used where the proof
  is genuinely visual.
* One block is explicitly labelled as illustrative rather than captured (the interactive
  `adduser` prompt sequence, since the capture was scripted). Everything else is real.
