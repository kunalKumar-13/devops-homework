# Networking Commands — Practice, Output and Notes

Every command below was run on **Ubuntu 26.04 LTS**. The `console` blocks are the real
output; the notes under each one are what I understood from it.

Tools installed first:

```bash
sudo apt install -y net-tools dnsutils traceroute iputils-ping curl wget \
                    netcat-openbsd telnet whois tcpdump nmap
```

---

## 1. Interfaces and IP addresses — `ip addr`, `ifconfig`, `hostname`

```console
$ ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:55:55:ed:79:6f brd ff:ff:ff:ff:ff:ff
    altname enx525555ed796f
    inet 192.168.5.15/24 metric 200 brd 192.168.5.255 scope global dynamic eth0
       valid_lft 3287sec preferred_lft 3287sec
    inet6 fe80::5055:55ff:feed:796f/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever

$ ip -brief addr
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             192.168.5.15/24 metric 200 fe80::5055:55ff:feed:796f/64 

$ ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.5.15  netmask 255.255.255.0  broadcast 192.168.5.255
        inet6 fe80::5055:55ff:feed:796f  prefixlen 64  scopeid 0x20<link>
        ether 52:55:55:ed:79:6f  txqueuelen 1000  (Ethernet)
        RX packets 31732  bytes 43154468 (43.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 4405  bytes 338106 (338.1 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 145  bytes 12694 (12.6 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 145  bytes 12694 (12.6 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0


$ hostname
lima-linuxlab

$ hostname -I
192.168.5.15 

$ hostname -f
lima-linuxlab
```

**What I understood**

* `ip addr show` (short: `ip a`) is the modern command and lists every network
  interface with its addresses. `lo` is the loopback (`127.0.0.1`), always present and
  never leaves the machine. `eth0` is the real ethernet interface with the machine's
  IPv4 address `192.168.5.15/24` — the `/24` is the subnet mask, so this host lives on
  the `192.168.5.x` network.
* Each interface line shows its **state** (`UP`/`DOWN`), its **MTU** (1500 bytes, the
  largest packet it will send) and its **MAC address** after `link/ether` — the
  hardware address used inside the local network.
* `ip -brief addr` is the same information in one compact line per interface — the
  version I would actually type when I just want the IP.
* `ifconfig` is the older `net-tools` command that does roughly the same thing. It is
  deprecated (not even installed by default on modern Ubuntu) but still very common in
  older docs and scripts, so it is worth recognising. It also shows RX/TX packet and
  error counters, which is handy for spotting a flaky link.
* `hostname` prints the machine name; `hostname -I` prints just the IP addresses, which
  is the easiest way to grab an IP inside a script.

---

## 2. Routing — `ip route`, `route -n`

```console
$ ip route
default via 192.168.5.2 dev eth0 proto dhcp src 192.168.5.15 metric 200 
192.168.5.0/24 dev eth0 proto kernel scope link src 192.168.5.15 metric 200 
192.168.5.2 dev eth0 proto dhcp scope link src 192.168.5.15 metric 200 

$ route -n
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
0.0.0.0         192.168.5.2     0.0.0.0         UG    200    0        0 eth0
192.168.5.0     0.0.0.0         255.255.255.0   U     200    0        0 eth0
192.168.5.2     0.0.0.0         255.255.255.255 UH    200    0        0 eth0

$ ip route get 8.8.8.8
8.8.8.8 via 192.168.5.2 dev eth0 src 192.168.5.15 uid 501 
    cache
```

**What I understood**

* The routing table decides **where a packet goes next**. `default via 192.168.5.2 dev
  eth0` means: anything not on my own subnet goes to the gateway `192.168.5.2`. That
  gateway is the router.
* The second line, `192.168.5.0/24 dev eth0 ... src 192.168.5.15`, says traffic for
  the local subnet goes straight out the interface with no router involved.
* `route -n` is the old `net-tools` equivalent; `-n` means "don't try to resolve names",
  which makes it instant.
* `ip route get 8.8.8.8` is the useful troubleshooting one — it tells you exactly which
  interface, gateway and source IP the kernel *would* use for a specific destination.
* If `ip route` shows **no default route**, the machine can talk to its own LAN but
  nothing on the internet. That is one of the first things to check when "the internet
  is down".

---

## 3. Reachability — `ping`

```console
$ ping -c 4 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=64 time=0.241 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=64 time=0.548 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=64 time=0.221 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=64 time=0.481 ms

--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3057ms
rtt min/avg/max/mdev = 0.221/0.372/0.548/0.143 ms

$ ping -c 3 google.com
PING google.com (192.178.174.113) 56(84) bytes of data.
64 bytes from 192.178.174.113: icmp_seq=1 ttl=64 time=0.514 ms
64 bytes from 192.178.174.113: icmp_seq=2 ttl=64 time=0.348 ms
64 bytes from 192.178.174.113: icmp_seq=3 ttl=64 time=0.314 ms

--- google.com ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2010ms
rtt min/avg/max/mdev = 0.314/0.392/0.514/0.087 ms
```

**What I understood**

* `ping` sends **ICMP echo request** packets and waits for echo replies. It answers the
  most basic question: *can I reach that host at all, and how long does it take?*
* `-c 4` sends exactly 4 packets and stops. Without it, ping runs forever until Ctrl+C.
* The important numbers are in the summary: **packet loss** (0% is healthy) and
  **round-trip min/avg/max/mdev** in milliseconds. High `mdev` (jitter) means an
  unstable link even if nothing is lost.
* `ping 8.8.8.8` (an IP) tests **connectivity**; `ping google.com` (a name) tests
  connectivity **and DNS**. If the IP works but the name does not, the problem is DNS,
  not the network — that single comparison is the fastest first diagnostic there is.
* `ttl=` in each reply is the remaining Time To Live. Each router decrements it by one,
  so a low TTL means the packet crossed many hops.

---

## 4. Path to a host — `traceroute`

```console
$ traceroute -m 8 google.com
traceroute to google.com (192.178.174.113), 8 hops max, 60 byte packets
 1  * * *
 2  * * *
 3  * * *
 4  * * *
 5  * * *
 6  * * *
 7  * * *
 8  * * *
```

**What I understood**

* `traceroute` shows **every router (hop)** between me and the destination, with the
  latency to each one. It works by sending packets with a deliberately small TTL —
  TTL=1 makes the first router reply "time exceeded", TTL=2 the second, and so on.
* Reading it: hop 1 is my own gateway, and latency should climb gradually. A sudden
  jump in time tells you *which* hop is slow; a row of `* * *` means that hop does not
  reply to traceroute (common — many routers drop it, and it is not automatically a
  fault).
* `-m 8` caps it at 8 hops so the command finishes quickly.
* Where ping says "reachable or not", traceroute says **where it breaks** — which is
  what you need when the problem is somewhere in the middle of the internet.

---

## 5. DNS lookups — `nslookup`, `dig`, `host`

```console
$ nslookup github.com
Server:		127.0.0.53
Address:	127.0.0.53#53

Non-authoritative answer:
Name:	github.com
Address: 20.207.73.82


$ dig github.com +short
20.207.73.82

$ dig github.com

; <<>> DiG 9.20.24-1ubuntu0.3-Ubuntu <<>> github.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 22320
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;github.com.			IN	A

;; ANSWER SECTION:
github.com.		0	IN	A	20.207.73.82

;; Query time: 1 msec
;; SERVER: 127.0.0.53#53(127.0.0.53) (UDP)
;; WHEN: Thu Sep 03 20:53:18 IST 2026
;; MSG SIZE  rcvd: 55


$ dig MX gmail.com +short
5 gmail-smtp-in.l.google.com.
10 alt1.gmail-smtp-in.l.google.com.
20 alt2.gmail-smtp-in.l.google.com.
30 alt3.gmail-smtp-in.l.google.com.
40 alt4.gmail-smtp-in.l.google.com.

$ dig -x 8.8.8.8 +short

$ host github.com
github.com has address 20.207.73.82
github.com mail is handled by 0 github-com.mail.protection.outlook.com.

$ cat /etc/resolv.conf
# This is /run/systemd/resolve/stub-resolv.conf managed by man:systemd-resolved(8).
# Do not edit.
#
# This file might be symlinked as /etc/resolv.conf. If you're looking at
# /etc/resolv.conf and seeing this text, you have followed the symlink.
#
# This is a dynamic resolv.conf file for connecting local clients to the
# internal DNS stub resolver of systemd-resolved. This file lists all
# configured search domains.
#
# Run "resolvectl status" to see details about the uplink DNS servers
# currently in use.
#
# Third party programs should typically not access this file directly, but only
# through the symlink at /etc/resolv.conf. To manage man:resolv.conf(5) in a
# different way, replace this symlink by a static file or a different symlink.
#
# See man:systemd-resolved.service(8) for details about the supported modes of
# operation for /etc/resolv.conf.

nameserver 127.0.0.53
options edns0 trust-ad
search .

$ cat /etc/hosts
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
192.168.5.2	host.lima.internal
```

**What I understood**

* DNS turns a **name into an IP address**. All three commands ask a DNS server to do
  that; they differ in how much detail they print.
* `nslookup github.com` shows the server that answered (`127.0.0.53`, the local
  `systemd-resolved` stub) and the resulting address. "Non-authoritative answer" simply
  means it came from a cache/resolver rather than from GitHub's own nameservers.
* `dig` is the detailed one used by admins. `dig github.com +short` prints just the IP —
  perfect inside scripts. The full `dig` output is split into sections:
  * **QUESTION** — what was asked
  * **ANSWER** — the records returned, with the **TTL** (how many seconds it may be cached)
  * **status: NOERROR** — the lookup succeeded (`NXDOMAIN` would mean "no such name")
  * **Query time** and **SERVER** — how long it took and who answered
* `dig MX gmail.com +short` looks up **mail servers** — record type matters. Other types:
  `A` (IPv4), `AAAA` (IPv6), `CNAME` (alias), `NS` (nameservers), `TXT` (SPF/verification).
* `dig -x 8.8.8.8` is a **reverse lookup** — IP back to a name. It came back **empty**
  here because the local stub resolver returned no PTR record for it; querying a public
  resolver directly (`dig -x 8.8.8.8 @8.8.8.8 +short`) is what returns `dns.google`.
* `host` is the simple middle ground: one line each for A, AAAA and MX records.
* `/etc/resolv.conf` names the resolver being used, and `/etc/hosts` is checked
  **before** DNS — which is why adding a line there can override any domain locally.

---

## 6. Open ports and sockets — `ss`, `netstat`

```console
$ ss -tuln
Netid State  Recv-Q Send-Q     Local Address:Port  Peer Address:Port
udp   UNCONN 0      0              127.0.0.1:323        0.0.0.0:*   
udp   UNCONN 0      0                0.0.0.0:5353       0.0.0.0:*   
udp   UNCONN 0      0             127.0.0.54:53         0.0.0.0:*   
udp   UNCONN 0      0          127.0.0.53%lo:53         0.0.0.0:*   
udp   UNCONN 0      0      192.168.5.15%eth0:68         0.0.0.0:*   
udp   UNCONN 0      0                  [::1]:323           [::]:*   
udp   UNCONN 0      0                   [::]:5353          [::]:*   
tcp   LISTEN 0      4096          127.0.0.54:53         0.0.0.0:*   
tcp   LISTEN 0      4096       127.0.0.53%lo:53         0.0.0.0:*   
tcp   LISTEN 0      4096             0.0.0.0:22         0.0.0.0:*   
tcp   LISTEN 0      4096           127.0.0.1:36917      0.0.0.0:*   
tcp   LISTEN 0      4096                [::]:22            [::]:*   

$ sudo ss -tulnp | head -n 15
Netid State  Recv-Q Send-Q     Local Address:Port  Peer Address:PortProcess                                                 
udp   UNCONN 0      0              127.0.0.1:323        0.0.0.0:*    users:(("chronyd",pid=1549,fd=4))                      
udp   UNCONN 0      0                0.0.0.0:5353       0.0.0.0:*    users:(("systemd-resolve",pid=2067,fd=13))             
udp   UNCONN 0      0             127.0.0.54:53         0.0.0.0:*    users:(("systemd-resolve",pid=2067,fd=21))             
udp   UNCONN 0      0          127.0.0.53%lo:53         0.0.0.0:*    users:(("systemd-resolve",pid=2067,fd=19))             
udp   UNCONN 0      0      192.168.5.15%eth0:68         0.0.0.0:*    users:(("systemd-network",pid=1294,fd=32))             
udp   UNCONN 0      0                  [::1]:323           [::]:*    users:(("chronyd",pid=1549,fd=5))                      
udp   UNCONN 0      0                   [::]:5353          [::]:*    users:(("systemd-resolve",pid=2067,fd=14))             
tcp   LISTEN 0      4096          127.0.0.54:53         0.0.0.0:*    users:(("systemd-resolve",pid=2067,fd=22))             
tcp   LISTEN 0      4096       127.0.0.53%lo:53         0.0.0.0:*    users:(("systemd-resolve",pid=2067,fd=20))             
tcp   LISTEN 0      4096             0.0.0.0:22         0.0.0.0:*    users:(("sshd",pid=1921,fd=3),("systemd",pid=1,fd=105))
tcp   LISTEN 0      4096           127.0.0.1:36917      0.0.0.0:*    users:(("containerd",pid=9730,fd=16))                  
tcp   LISTEN 0      4096                [::]:22            [::]:*    users:(("sshd",pid=1921,fd=4),("systemd",pid=1,fd=106))

$ netstat -tuln | head -n 15
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State      
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN     
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN     
tcp        0      0 127.0.0.1:36917         0.0.0.0:*               LISTEN     
tcp6       0      0 :::22                   :::*                    LISTEN     
udp        0      0 127.0.0.1:323           0.0.0.0:*                          
udp        0      0 0.0.0.0:5353            0.0.0.0:*                          
udp        0      0 127.0.0.54:53           0.0.0.0:*                          
udp        0      0 127.0.0.53:53           0.0.0.0:*                          
udp        0      0 192.168.5.15:68         0.0.0.0:*                          
udp6       0      0 ::1:323                 :::*                               
udp6       0      0 :::5353                 :::*                               

$ sudo netstat -tulnp | head -n 12
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.54:53           0.0.0.0:*               LISTEN      2067/systemd-resolv 
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      2067/systemd-resolv 
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1/systemd           
tcp        0      0 127.0.0.1:36917         0.0.0.0:*               LISTEN      9730/containerd     
tcp6       0      0 :::22                   :::*                    LISTEN      1/systemd           
udp        0      0 127.0.0.1:323           0.0.0.0:*                           1549/chronyd        
udp        0      0 0.0.0.0:5353            0.0.0.0:*                           2067/systemd-resolv 
udp        0      0 127.0.0.54:53           0.0.0.0:*                           2067/systemd-resolv 
udp        0      0 127.0.0.53:53           0.0.0.0:*                           2067/systemd-resolv 
udp        0      0 192.168.5.15:68         0.0.0.0:*                           1294/systemd-networ 

$ ss -s
Total: 215
TCP:   8 (estab 0, closed 3, orphaned 0, timewait 3)

Transport Total     IP        IPv6
RAW	  1         0         1        
UDP	  7         5         2        
TCP	  5         4         1        
INET	  13        9         4        
FRAG	  0         0         0
```

**What I understood**

* These answer: *what is listening on this machine, and who is connected?*
* `ss` is the modern replacement for `netstat` and is much faster. The flags I actually
  use are `-tulnp`:
  * `-t` TCP, `-u` UDP
  * `-l` only **listening** sockets
  * `-n` numeric — don't resolve ports to names (so `22`, not `ssh`)
  * `-p` show the **process** holding the socket (needs `sudo`)
* In the output, `LISTEN` with `0.0.0.0:22` means sshd accepts connections on **every**
  interface; something bound to `127.0.0.1:x` only accepts local connections — that
  distinction is exactly why a service can look "up" locally but be unreachable from
  outside.
* `netstat -tulnp` prints the same information; it comes from the older `net-tools`
  package and is what most tutorials still show.
* `ss -s` gives a summary count of sockets by state — useful for spotting a machine
  drowning in `TIME-WAIT` connections.
* This is the command I would use to answer "is my app actually listening on port 8080?"
  before blaming the firewall.

---

## 7. ARP / neighbour table — `ip neigh`, `arp -n`

```console
$ ip neigh
192.168.5.2 dev eth0 lladdr 5a:94:ef:e4:0c:dd DELAY 

$ arp -n
Address                  HWtype  HWaddress           Flags Mask            Iface
192.168.5.2              ether   5a:94:ef:e4:0c:dd   C                     eth0
```

**What I understood**

* Inside a local network, machines are found by **MAC address**, not IP. ARP is the
  protocol that asks "who has 192.168.5.2?" and caches the answer.
* `ip neigh` (modern) and `arp -n` (older) both print that cache: IP → MAC → interface,
  plus a state such as `REACHABLE`, `STALE` or `DELAY`.
* It only ever contains hosts on the **same subnet** — anything further away is reached
  through the gateway, so only the gateway's MAC appears.
* Useful for spotting duplicate IPs or a device that has changed its network card.

---

## 8. HTTP clients — `curl`, `wget`

```console
$ curl -s -I https://example.com
HTTP/2 200 
date: Thu, 03 Sep 2026 15:23:19 GMT
content-type: text/html
server: cloudflare
last-modified: Wed, 02 Sep 2026 22:14:26 GMT
allow: GET, HEAD
accept-ranges: bytes
age: 10930
cf-cache-status: HIT
cf-ray: a355c1442b109145-MAA


$ curl -s https://api.github.com/zen
Favor focus over features.
$ curl -s -o /dev/null -w 'http_code=%{http_code} time_total=%{time_total}s\n' https://github.com
http_code=200 time_total=0.203512s

$ wget -q -O - https://example.com | head -n 10
<!doctype html><html lang="en"><head><title>Example Domain</title><link rel="icon" href="data:,"><meta name="viewport" content="width=device-width, initial-scale=1"><style>body{background:#eee;width:60vw;margin:15vh auto;font-family:system-ui,sans-serif}h1{font-size:1.5em}div{opacity:0.8}a:link,a:visited{color:#348}</style></head><body><div><h1>Example Domain</h1><p>This domain is for use in documentation examples without needing permission. Avoid use in operations.</p><p><a href="https://iana.org/domains/example">Learn more</a></p></div></body></html>
```

**What I understood**

* `curl` speaks HTTP(S) from the command line and is the standard tool for testing an
  API or a web server.
  * `-I` fetches only the **headers** — the fastest way to see a status code, the server
    software and redirects.
  * `-s` silences the progress meter (essential when piping).
  * `-o /dev/null -w '%{http_code} %{time_total}'` throws the body away and prints just
    the status code and total time — exactly what a health check needs.
  * Other flags worth knowing: `-L` follow redirects, `-X POST -d '...'` send data,
    `-H 'Header: value'` add a header, `-k` skip certificate checks.
* `wget` is aimed at **downloading files** rather than inspecting responses; `-O -`
  sends the body to stdout instead of saving it. `wget -c` resumes a broken download,
  which curl cannot do as simply.
* Rule of thumb: **curl to test**, **wget to download**.

---

## 9. Port checks — `nc` (netcat), `telnet`

```console
$ nc -zv github.com 443
Connection to github.com (20.207.73.82) 443 port [tcp/https] succeeded!

$ nc -zv github.com 22
Connection to github.com (20.207.73.82) 22 port [tcp/ssh] succeeded!

$ timeout 5 telnet github.com 443 </dev/null 2>&1 | head -n 4
Trying 20.207.73.82...
Connected to github.com.
Escape character is '^]'.
Connection closed by foreign host.
```

**What I understood**

* `nc -zv host port` is the cleanest way to ask *is this TCP port open?* — `-z` means
  "just scan, send no data", `-v` prints the verdict. `succeeded!` means the TCP
  handshake completed.
* This is the check that distinguishes a **firewall problem** from an **application
  problem**: if ping works but the port is closed, something is blocking that port or
  the service is not listening.
* `telnet host port` does the same job in a pinch and is available on almost any box.
  It is obsolete as a login protocol (everything is in plaintext — use SSH), but as a
  "can I open this port" probe it is still handy. Getting the raw banner back (here the
  TLS handshake bytes) proves the connection was established.
* `nc` can also listen (`nc -l 9000`) which makes it a quick way to test connectivity in
  both directions.

---

## 10. Scanning and packet capture — `nmap`, `tcpdump`

```console
$ nmap -F localhost
Starting Nmap 7.98 ( https://nmap.org ) at 2026-09-03 20:53 +0530
Nmap scan report for localhost (127.0.0.1)
Host is up (0.000045s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 99 closed tcp ports (conn-refused)
PORT   STATE SERVICE
22/tcp open  ssh

Nmap done: 1 IP address (1 host up) scanned in 0.02 seconds

$ sudo timeout 6 tcpdump -i any -c 5 -n icmp & sleep 1; ping -c 3 8.8.8.8 >/dev/null; wait
tcpdump: WARNING: any: That device doesn't support promiscuous mode
(Promiscuous mode not supported on the "any" device)
tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on any, link-type LINUX_SLL2 (Linux cooked v2), snapshot length 262144 bytes
20:53:20.772016 eth0  Out IP 192.168.5.15 > 8.8.8.8: ICMP echo request, id 54317, seq 1, length 64
20:53:20.772354 eth0  In  IP 8.8.8.8 > 192.168.5.15: ICMP echo reply, id 54317, seq 1, length 64
20:53:21.830961 eth0  Out IP 192.168.5.15 > 8.8.8.8: ICMP echo request, id 54317, seq 2, length 64
20:53:21.831181 eth0  In  IP 8.8.8.8 > 192.168.5.15: ICMP echo reply, id 54317, seq 2, length 64
20:53:22.854288 eth0  Out IP 192.168.5.15 > 8.8.8.8: ICMP echo request, id 54317, seq 3, length 64
5 packets captured
6 packets received by filter
0 packets dropped by kernel
```

**What I understood**

* `nmap -F localhost` does a **fast scan** of the most common ports and reports which
  are open, with the service name it guesses from the port number. It is the tool for
  auditing what a machine actually exposes. (Only ever run it against hosts you are
  allowed to scan.)
* `tcpdump` captures **actual packets** on the wire. `-i any` listens on all interfaces,
  `-c 5` stops after 5 packets, `-n` skips name resolution, and the trailing `icmp` is a
  filter expression. Running `ping` alongside it shows the echo request/reply pairs
  appear in the capture in real time.
* Reading a tcpdump line: timestamp, interface, `source > destination`, protocol and
  details. Filters can be much tighter, e.g. `tcpdump -i any port 80 and host 10.0.0.5`.
* This is the last-resort tool: when the logs of both sides disagree, tcpdump shows what
  was really transmitted.

---

## 11. Public IP and `whois`

```console
$ curl -s ifconfig.me; echo
<redacted — this machine's public IP>

$ whois github.com | head -n 12
   Domain Name: GITHUB.COM
   Registry Domain ID: 1264983250_DOMAIN_COM-VRSN
   Registrar WHOIS Server: whois.markmonitor.com
   Registrar URL: http://www.markmonitor.com
   Updated Date: 2024-09-07T09:16:32Z
   Creation Date: 2007-10-09T18:20:50Z
   Registry Expiry Date: 2026-10-09T18:20:50Z
   Registrar: MarkMonitor Inc.
   Registrar IANA ID: 292
   Registrar Abuse Contact Email: abusecomplaints@markmonitor.com
   Registrar Abuse Contact Phone: +1.2086851750
   Domain Status: clientDeleteProhibited https://icann.org/epp#clientDeleteProhibited
```

**What I understood**

* `curl -s ifconfig.me` returns the **public IP** (redacted in the block above) the internet sees, which is different
  from the private `192.168.x.x` address on the interface because of NAT. Useful for
  allow-listing an office or a server.
* `whois github.com` queries the domain registry: registrar, creation and expiry dates,
  nameservers and status flags. Good for checking who owns a domain and when it expires;
  most contact details are redacted for privacy these days.

---

## Quick reference

| Question | Command |
|---|---|
| What is my IP? | `ip -brief addr` · `hostname -I` |
| What is my gateway? | `ip route` |
| Can I reach that host? | `ping -c 4 host` |
| Where does it break? | `traceroute host` |
| Does the name resolve? | `dig host +short` · `nslookup host` |
| What is listening here? | `sudo ss -tulnp` |
| Is that port open there? | `nc -zv host port` |
| What does the server reply? | `curl -I https://host` |
| What is on the wire? | `sudo tcpdump -i any -n port 443` |
| What ports does it expose? | `nmap -F host` |
| What is my public IP? | `curl ifconfig.me` |

### The order I would actually debug in

1. `ip a` — do I have an IP at all?
2. `ip route` — do I have a default gateway?
3. `ping 8.8.8.8` — is the network reachable by IP?
4. `ping google.com` / `dig google.com` — is DNS working?
5. `nc -zv host port` — is the specific port reachable?
6. `curl -I https://host` — is the application actually answering?
7. `ss -tulnp` on the server — is it even listening, and on the right address?
