# Networking Homework Tasks

## Task 1 — Practise the commands from the class repo

The session referred to a **`devops-hero`** GitHub repo, but the exact URL was not in
the assignment text I was given, so rather than guess at a repository I worked through
the standard Linux networking command set that such a repo covers, end to end, on a
real Ubuntu machine.

Commands practised:

`ip addr` · `ip -brief addr` · `ifconfig` · `hostname` · `hostname -I` · `ip route` ·
`route -n` · `ip route get` · `ping` · `traceroute` · `nslookup` · `dig` · `dig MX` ·
`dig -x` · `host` · `/etc/resolv.conf` · `/etc/hosts` · `ss -tuln` · `ss -tulnp` ·
`ss -s` · `netstat -tuln` · `netstat -tulnp` · `ip neigh` · `arp -n` · `curl` ·
`curl -I` · `wget` · `nc -zv` · `telnet` · `nmap -F` · `tcpdump` · `whois` ·
`curl ifconfig.me`

> If the class repo link is shared later, cloning it and re-running its exercises is a
> five-minute job on top of this — the environment is already set up.

## Task 2 — Markdown file with the output and an explanation of each command

**→ [`networking-commands.md`](networking-commands.md)**

That file contains, for each group of commands:

* the exact command that was run,
* its **real captured output** (Ubuntu 26.04 LTS, `console` blocks),
* a **"What I understood"** section explaining what the command is for, how to read its
  output, and when I would reach for it.

It ends with a quick-reference table and the order I would actually work through when
debugging a network problem.

## Environment

```bash
limactl start --name=linuxlab template://ubuntu-lts
limactl shell linuxlab
sudo apt install -y net-tools dnsutils traceroute iputils-ping curl wget \
                    netcat-openbsd telnet whois tcpdump nmap
```

Machine used: hostname `lima-linuxlab`, interface `eth0`, IP `192.168.5.15/24`,
gateway `192.168.5.2`.

**Two commands were run on the host machine instead of in the VM: `ping` and
`traceroute`.** The VM sits behind a user-mode network stack that answers ICMP itself
rather than forwarding it, so inside the VM `ping 8.8.8.8` returns an impossible
`ttl=64` at 0.2 ms and `traceroute` returns `* * *` for every hop. Both the real
host output and the misleading VM output are in the file, with an explanation of why
they differ — a successful ping only proves that *something* replied.

## A note on evidence

The task asks for "output/screenshots". Everything here is captured **text output**
rather than image screenshots — it is the same evidence, but it is searchable,
copy-pasteable, diffable in git, and readable on a phone. The machine's public IP was
redacted from the `ifconfig.me` output since this repository is public.
