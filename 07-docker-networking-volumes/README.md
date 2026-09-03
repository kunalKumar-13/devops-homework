# Docker Networking & Volume Homework

All four tasks were run against a real Docker engine. Every `console` block below is
captured output.

```
07-docker-networking-volumes/
├── README.md
├── bind-mount/
│   └── index.html          the file bind-mounted into the Nginx container
└── screenshots/
    ├── bind-mount-before.png
    └── bind-mount-after.png
```

---

# Task 1 — Docker Container Networking

Three containers, three networks, with the **backend attached to two of them**.

```
   frontend-net (172.18.0.0/16)          backend-net (172.19.0.0/16)
   ┌───────────────────────────┐   ┌──────────────────────────────┐
   │  frontend (nginx:alpine)  │   │   database (mysql:8)         │
   │        172.18.0.2         │   │        172.19.0.2            │
   │                           │   │                              │
   │      backend (alpine) ────┼───┼──── backend (alpine)         │
   │        172.18.0.3         │   │        172.19.0.3            │
   └───────────────────────────┘   └──────────────────────────────┘
            ↑ same container, one interface on each network

   monitoring-net — the third network, no containers attached
```

`frontend` and `database` share **no** network, so they cannot reach each other. Only
`backend` can talk to both. That is exactly how a real three-tier app is isolated: the
database is never exposed to the web tier directly.

## Commands

```bash
docker network create frontend-net
docker network create backend-net
docker network create monitoring-net

docker run -d --name frontend --network frontend-net nginx:alpine
docker run -d --name backend  --network frontend-net alpine sleep 3600
docker run -d --name database --network backend-net \
           -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=appdb mysql:8

docker network connect backend-net backend     # backend joins its SECOND network

docker exec backend ping -c 2 frontend         # works
docker exec backend ping -c 2 database         # works
docker exec frontend ping -c 2 database        # FAILS — no shared network
```

## Output

```console
--- 1.1 Create 3 different Docker networks ---
$ docker network create frontend-net
d6f45db0588007dc004b679a10b75de2978c6371ea13ea57b9d68524507490b6

$ docker network create backend-net
81f6a029ef79b3449be0b15c1a9b88c1a14361c722d70472d978910411e7093d

$ docker network create monitoring-net
892f3912c1cafe8c7fb60ff7291cccc23588f46a90d2928529de41903801525e

$ docker network ls
NETWORK ID     NAME             DRIVER    SCOPE
81f6a029ef79   backend-net      bridge    local
d16f34ded28e   bridge           bridge    local
d6f45db05880   frontend-net     bridge    local
e0d03eb9a6ad   host             host      local
892f3912c1ca   monitoring-net   bridge    local
ff8e223925e7   none             null      local

--- 1.2 Create the 3 containers ---
$ docker run -d --name frontend --network frontend-net nginx:alpine
101c3a5dffeb2f67ad7746c7ce0a147692a25854cd0c5ae15c85034ee9e6836b

$ docker run -d --name backend  --network frontend-net alpine sleep 3600
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
df8ce8557afe: Download complete
aa3ec251a2db: Download complete
Digest: sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
Status: Downloaded newer image for alpine:latest
0701442b3df8b8259ec85f06d79b88340039d3b7a1fa08406ae460dd008b8b70

$ docker run -d --name database --network backend-net -e MYSQL_ROOT_PASSWORD=rootpass -e MYSQL_DATABASE=appdb mysql:8
Unable to find image 'mysql:8' locally
8: Pulling from library/mysql
c1a8d43326b8: Pulling fs layer
26eb9d6698f0: Pulling fs layer
8a905d3b3fdf: Pulling fs layer
3d7f10ed4edf: Pulling fs layer
bec4c5f6b46d: Pulling fs layer
b12e28485eff: Pulling fs layer
ac21e899ba1c: Pulling fs layer
1ff71ea7626e: Pulling fs layer
19c1e4d5e56d: Pulling fs layer
d3c86b417a74: Pulling fs layer
26eb9d6698f0: Download complete
8a905d3b3fdf: Download complete
b12e28485eff: Download complete
d3c86b417a74: Download complete
3d7f10ed4edf: Download complete
1ff71ea7626e: Download complete
64896815bd4e: Download complete
ac21e899ba1c: Download complete
541dad502f35: Download complete
bec4c5f6b46d: Download complete
c1a8d43326b8: Download complete
8a905d3b3fdf: Pull complete
3d7f10ed4edf: Pull complete
ac21e899ba1c: Pull complete
c1a8d43326b8: Pull complete
d3c86b417a74: Pull complete
1ff71ea7626e: Pull complete
b12e28485eff: Pull complete
bec4c5f6b46d: Pull complete
19c1e4d5e56d: Download complete
26eb9d6698f0: Pull complete
19c1e4d5e56d: Pull complete
Digest: sha256:b3b90af2a6552ae30c266fdb7d5dd55f3afb72404bb78d37fe8a23eb857fd3fb
Status: Downloaded newer image for mysql:8
18a1f405c07f4269f3cafdcfaa08214bf917533753325b6d875ffb16cefbae0c

--- 1.3 Add the backend container to a SECOND network ---
$ docker network connect backend-net backend

$ docker inspect backend --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}={{$v.IPAddress}} {{end}}'
backend-net=172.19.0.3 frontend-net=172.18.0.3 

--- 1.4 Which container sits on which network ---
$ docker network inspect frontend-net --format 'frontend-net -> {{range .Containers}}{{.Name}} ({{.IPv4Address}}) {{end}}'
frontend-net -> backend (172.18.0.3/16) frontend (172.18.0.2/16) 

$ docker network inspect backend-net --format 'backend-net -> {{range .Containers}}{{.Name}} ({{.IPv4Address}}) {{end}}'
backend-net -> backend (172.19.0.3/16) database (172.19.0.2/16) 

$ docker network inspect monitoring-net --format 'monitoring-net -> {{range .Containers}}{{.Name}} ({{.IPv4Address}}) {{end}}'
monitoring-net -> 

--- 1.5 Connectivity checks ---
backend -> frontend (SAME network frontend-net): expected SUCCESS
$ docker exec backend ping -c 2 frontend
PING frontend (172.18.0.2): 56 data bytes
64 bytes from 172.18.0.2: seq=0 ttl=64 time=0.578 ms
64 bytes from 172.18.0.2: seq=1 ttl=64 time=0.167 ms

--- frontend ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.167/0.372/0.578 ms

backend -> database (SAME network backend-net): expected SUCCESS
$ docker exec backend ping -c 2 database
PING database (172.19.0.2): 56 data bytes
64 bytes from 172.19.0.2: seq=0 ttl=64 time=0.470 ms
64 bytes from 172.19.0.2: seq=1 ttl=64 time=0.609 ms

--- database ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.470/0.539/0.609 ms

frontend -> backend (SAME network frontend-net): expected SUCCESS
$ docker exec frontend ping -c 2 backend
PING backend (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.066 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.112 ms

--- backend ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.066/0.089/0.112 ms

frontend -> database (NO shared network): expected FAILURE
$ docker exec frontend ping -c 2 database
ping: bad address 'database'
(exit code: 1)

DNS resolution by container name is provided by Docker's embedded DNS:
$ docker exec backend nslookup frontend 2>&1 | tail -n 4
Non-authoritative answer:
Name:	frontend
Address: 172.18.0.2


$ docker exec backend nslookup database 2>&1 | tail -n 4
Non-authoritative answer:
Name:	database
Address: 172.19.0.2


The backend can even talk to MySQL on port 3306:
$ docker exec backend sh -c 'nc -z -w 3 database 3306 && echo "port 3306 on database is OPEN from backend"'
port 3306 on database is OPEN from backend
```

## What this shows

* `docker network create` makes a **user-defined bridge** network. Each one gets its own
  subnet — `172.18.0.0/16` and `172.19.0.0/16` here — and its own virtual bridge on the
  host.
* On a user-defined bridge, Docker runs an **embedded DNS server**, so containers reach
  each other **by container name**. `ping frontend` resolves to `172.18.0.2` without any
  `/etc/hosts` editing. (This does *not* work on the legacy default `bridge` network —
  that is the main reason to always create your own.)
* `docker network connect backend-net backend` attached the running container to a
  second network **without restarting it**. `docker inspect` then shows it holding two
  IPs: `frontend-net=172.18.0.3` and `backend-net=172.19.0.3`.
* **The isolation is real.** `docker exec frontend ping database` failed with
  `ping: bad address 'database'` — the name does not even resolve, because the two
  containers share no network. Nothing was blocked by a firewall rule; they simply
  cannot see each other.
* `nc -z database 3306` from `backend` succeeded, proving the backend can actually reach
  MySQL's port, not just ping it.

**Network drivers, in short**

| Driver | What it is for |
|---|---|
| `bridge` | the default — containers on one host, isolated from the host network |
| `host` | container shares the host's network namespace (Task 2) |
| `none` | no networking at all |
| `overlay` | one virtual network spanning **multiple** Docker hosts (Task 4) |
| `macvlan` | container gets its own MAC and appears as a physical device on the LAN |

---

# Task 2 — Host Network

```bash
docker pull httpd:2.4
docker run -d --name apache-host --network host httpd:2.4
curl http://localhost:80
```

## Output

```console
$ docker pull httpd:2.4
2.4: Pulling from library/httpd
Digest: sha256:979c38c2228d28c2edfd45c6e27dcee1c7b4a101a5526721ae8ece454e89e99e
Status: Image is up to date for httpd:2.4
docker.io/library/httpd:2.4

$ docker run -d --name apache-host --network host httpd:2.4
2d79abde724836c158a8823751454e7323a358c3c4d94a06575122050a4804bb

$ docker ps --filter name=apache-host --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES         IMAGE       STATUS         PORTS
apache-host   httpd:2.4   Up 3 seconds   

Note: with --network host the container shares the host's network namespace,
so NO -p flag is used and the PORTS column is empty — Apache binds port 80 directly.

Docker Desktop / Colima run the Docker engine inside a Linux VM, so 'the host'
for host networking is that Linux VM. Verifying from inside it:
$ colima ssh -- curl -s -I http://localhost:80
HTTP/1.1 200 OK
Date: Thu, 03 Sep 2026 15:27:00 GMT
Server: Apache/2.4.68 (Unix)
Last-Modified: Fri, 07 Nov 2025 08:23:08 GMT
ETag: "bf-642fce432f300"
Accept-Ranges: bytes
Content-Length: 191
Content-Type: text/html


$ colima ssh -- curl -s http://localhost:80
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>

$ colima ssh -- sudo ss -tlnp | grep ':80 '
LISTEN 0      511                                   *:80              *:*    users:(("httpd",pid=7451,fd=4),("httpd",pid=7450,fd=4),("httpd",pid=7449,fd=4),("httpd",pid=7434,fd=4))

$ docker exec apache-host sh -c 'echo inside-container; hostname'
inside-container
colima
```

## What this shows

* With `--network host` the container **does not get its own network namespace** — it
  uses the host's. So there is **no `-p` flag**, and `docker ps` shows an **empty PORTS
  column**: there is no port mapping, because there is no boundary to map across.
* Apache bound directly to the host's port 80. `ss -tlnp` on the host shows the `httpd`
  processes listening on `*:80` as ordinary host processes.
* `hostname` inside the container returns the **host's** hostname (`colima`) rather than
  a container ID — more evidence that the namespace is shared.

**Trade-offs**

| | Bridge + `-p` | `--network host` |
|---|---|---|
| Isolation | container has its own network stack | none — shares the host's |
| Port mapping | `-p 8080:80` remaps freely | impossible; the app binds the real port |
| Port conflicts | none — many containers can use port 80 internally | two containers cannot both bind 80 |
| Performance | one NAT hop | slightly faster, no NAT |
| Portability | works everywhere | **Linux only** |

Use it for high-throughput network tools or when a service needs to see real client IPs;
avoid it otherwise, because you lose isolation and the ability to run two copies.

> **Important detail on macOS/Windows:** Docker Desktop and Colima run the Docker engine
> inside a Linux VM, so "the host" for host networking is **that Linux VM**, not the Mac.
> That is why the verification above was done with `colima ssh -- curl localhost:80`
> rather than from the Mac's browser. On a native Linux machine, `http://localhost` in
> the browser is all it takes.

---

# Task 3 — Bind Mount

```bash
mkdir bind-mount
echo "Hello students" > bind-mount/index.html      # (as a full HTML page)

docker run -d --name nginx-bind -p 8090:80 \
  -v "$PWD/bind-mount":/usr/share/nginx/html:ro nginx:alpine

curl http://localhost:8090        # serves the host file
# edit bind-mount/index.html on the host
curl http://localhost:8090        # changed immediately, no restart
```

## Output

```console
$ ls -la /Users/kunalpronto/personal/repos/devops-homework/07-docker-networking-volumes/bind-mount
total 8
drwxr-xr-x@ 3 kunalpronto  staff   96  3 Sep 20:57 .
drwxr-xr-x@ 5 kunalpronto  staff  160  3 Sep 21:14 ..
-rw-r--r--@ 1 kunalpronto  staff  207  3 Sep 21:14 index.html

$ cat /Users/kunalpronto/personal/repos/devops-homework/07-docker-networking-volumes/bind-mount/index.html
<!doctype html>
<html>
  <head><title>Bind mount demo</title></head>
  <body style="font-family: system-ui, sans-serif; text-align: center; padding-top: 80px;">
    <h1>Hello students</h1>
  </body>
</html>

$ docker run -d --name nginx-bind -p 8090:80 -v /Users/kunalpronto/personal/repos/devops-homework/07-docker-networking-volumes/bind-mount:/usr/share/nginx/html:ro nginx:alpine
d12bd8ccd3b4c82652fa38ef23b80f26ac109e956ac510ab6db9c00c4810fa8a

$ docker ps --filter name=nginx-bind --format "table {{.Names}}	{{.Status}}	{{.Ports}}"
NAMES        STATUS         PORTS
nginx-bind   Up 3 seconds   0.0.0.0:8090->80/tcp, [::]:8090->80/tcp

$ docker inspect nginx-bind --format "{{range .Mounts}}{{.Type}}: {{.Source}} -> {{.Destination}} (rw={{.RW}}){{end}}"
bind: /Users/kunalpronto/personal/repos/devops-homework/07-docker-networking-volumes/bind-mount -> /usr/share/nginx/html (rw=false)

--- Serving the file straight from the host folder ---
$ curl -s http://localhost:8090
<!doctype html>
<html>
  <head><title>Bind mount demo</title></head>
  <body style="font-family: system-ui, sans-serif; text-align: center; padding-top: 80px;">
    <h1>Hello students</h1>
  </body>
</html>

--- Now MODIFY index.html on the host, WITHOUT touching the container ---
$ (add a <p> line to bind-mount/index.html on the host)

$ cat /Users/kunalpronto/personal/repos/devops-homework/07-docker-networking-volumes/bind-mount/index.html
<!doctype html>
<html>
  <head><title>Bind mount demo</title></head>
  <body style="font-family: system-ui, sans-serif; text-align: center; padding-top: 80px;">
    <h1>Hello students</h1>
    <p>This line was added on the host while the container kept running &mdash; no restart needed.</p>
  </body>
</html>

$ curl -s http://localhost:8090
<!doctype html>
<html>
  <head><title>Bind mount demo</title></head>
  <body style="font-family: system-ui, sans-serif; text-align: center; padding-top: 80px;">
    <h1>Hello students</h1>
    <p>This line was added on the host while the container kept running &mdash; no restart needed.</p>
  </body>
</html>

>>> The change is live. The container was never restarted:
$ docker ps --filter name=nginx-bind --format "{{.Names}} has been {{.Status}}"
nginx-bind has been Up 4 seconds
```

## Screenshots

| Before the edit | After editing `index.html` on the host |
|---|---|
| ![before](screenshots/bind-mount-before.png) | ![after](screenshots/bind-mount-after.png) |

The container was **never restarted** between those two screenshots — the same
`nginx-bind` container served both, and `docker ps` shows its uptime simply continuing.

## What this shows

* A **bind mount** maps a directory from the host straight into the container. Both
  sides see the *same* files on the *same* filesystem; there is no copying and no
  syncing, so a change on the host is visible inside the container instantly.
* `docker inspect` confirms the mount type is `bind`, with the host path as `Source` and
  `/usr/share/nginx/html` as `Destination`. The `:ro` suffix made it read-only from the
  container's side (`rw=false`) — the container can serve the files but cannot modify
  them, which is what you want for static content.
* This is why bind mounts are the standard **development** setup: edit a file in your
  editor and reload the browser, with no rebuild and no restart.

**Bind mount vs named volume**

| | Bind mount (`-v /host/path:/in/container`) | Named volume (`-v myvol:/in/container`) |
|---|---|---|
| Where the data lives | a path you choose on the host | managed by Docker in `/var/lib/docker/volumes` |
| Host layout | must exist and match | irrelevant |
| Best for | **development**, config files, static content | **production data** — databases, uploads |
| Portable | no — depends on the host path | yes |
| Managed by Docker | no | yes (`docker volume ls/create/rm`, backups, drivers) |

---

# Task 4 — Overlay Network

The other three tasks used **bridge** networks, which only connect containers on a
single Docker host. An **overlay** network connects containers running on **different
hosts** as if they were on one LAN.

## How it works

```
        Host A (10.0.0.1)                      Host B (10.0.0.2)
 ┌───────────────────────────┐         ┌───────────────────────────┐
 │  web.1     10.0.1.5       │         │  api.1     10.0.1.7       │
 │  web.2     10.0.1.6       │         │  api.2     10.0.1.8       │
 └──────────┬────────────────┘         └───────────────┬───────────┘
            │      VXLAN tunnel (UDP 4789) over the physical network
            └────────────────────────────────────────────┘
              one virtual L2 network: 10.0.1.0/24
```

1. Docker creates a **VXLAN** tunnel between the hosts. Each container's ethernet frame
   is wrapped inside a UDP packet (port **4789**), sent across the real network, and
   unwrapped on the other side.
2. Every container gets an IP from the overlay's own subnet (`10.0.1.0/24` in the run
   below), independent of the hosts' physical addressing.
3. A distributed key-value store (built into Swarm mode, or Consul/etcd for standalone
   Docker) keeps every host's copy of the network state in sync.
4. Docker's embedded DNS resolves **service names** across all hosts, and load balances
   across replicas via a virtual IP (VIP).

## Ports that must be open between hosts

| Port | Protocol | Purpose |
|---|---|---|
| 2377 | TCP | Swarm cluster management |
| 7946 | TCP + UDP | node-to-node discovery / gossip |
| 4789 | UDP | VXLAN data plane (the actual container traffic) |

## Use cases

* **Multi-host container orchestration** — Docker Swarm and Kubernetes both need a
  network that spans nodes; containers must talk by name regardless of which machine
  they landed on.
* **Scaling a service across machines** — replicas of `web` on five hosts all reachable
  as `web`, with the VIP spreading traffic across them.
* **Microservices split across hosts** — `api` on one node reaching `db` on another
  without publishing the database to the physical network.
* **Rescheduling** — when a container dies and is restarted on a different host, the
  name keeps resolving; nothing else needs reconfiguring.
* **Encryption in transit** — `docker network create -d overlay --opt encrypted` turns on
  IPsec between hosts.

## Live demonstration (single-node swarm)

```console
$ docker swarm init 2>&1 | head -n 3
Swarm initialized: current node (2sgfjwop5q7u9yzdvq13c51hi) is now a manager.

To add a worker to this swarm, run the following command:

$ docker network create -d overlay --attachable my-overlay
sj94us83275yxnztd2krk1e5p

$ docker network ls --filter driver=overlay
NETWORK ID     NAME         DRIVER    SCOPE
n6bwzwfnlo1y   ingress      overlay   swarm
sj94us83275y   my-overlay   overlay   swarm

$ docker network inspect my-overlay --format 'name={{.Name}} driver={{.Driver}} scope={{.Scope}} subnet={{range .IPAM.Config}}{{.Subnet}}{{end}}'
name=my-overlay driver=overlay scope=swarm subnet=10.0.1.0/24

$ docker service create --name overlay-web --network my-overlay --replicas 2 nginx:alpine 2>&1 | tail -n 3
verify: Waiting 1 seconds to verify that tasks are stable...
verify: Waiting 1 seconds to verify that tasks are stable...
verify: Service pid2s8tioaxjela1sfkkb3l46 converged

$ docker service ls
ID             NAME          MODE         REPLICAS   IMAGE          PORTS
pid2s8tioaxj   overlay-web   replicated   2/2        nginx:alpine   

$ docker service ps overlay-web --format 'table {{.Name}}\t{{.Node}}\t{{.CurrentState}}'
NAME            NODE      CURRENT STATE
overlay-web.1   colima    Running 13 seconds ago
overlay-web.2   colima    Running 13 seconds ago

$ docker run --rm --network my-overlay alpine sh -c 'nslookup overlay-web 2>&1 | tail -n 4; wget -qO- http://overlay-web | head -n 5'
Address: 10.0.1.2

Non-authoritative answer:

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>

--- cleanup of the swarm demo ---
$ docker service rm overlay-web
overlay-web

$ docker network rm my-overlay
my-overlay

$ docker swarm leave --force
Node left the swarm.
```

Even on one node the mechanics are visible:

* `docker network create -d overlay` produced a network whose **scope is `swarm`**, not
  `local` like a bridge — the network definition is stored in the cluster, not on one
  host, and appears on every node that runs a task on it.
* It allocated its own subnet, `10.0.1.0/24`, separate from the bridge networks'
  `172.x` ranges.
* A `docker service` with **2 replicas** was scheduled on it, and a separate container
  attached with `--network my-overlay` resolved `overlay-web` by name and fetched the
  Nginx page. On a real multi-node swarm the replicas would sit on different machines
  and that lookup would work identically.
* `--attachable` is what allows a plain `docker run` container to join a swarm-scoped
  network; without it only swarm services can attach.

**Overlay vs bridge, in one line:** bridge connects containers on **one** host; overlay
connects containers across **many** hosts by tunnelling their traffic over the physical
network.

---

## Cleanup

```bash
docker rm -f frontend backend database apache-host nginx-bind
docker network rm frontend-net backend-net monitoring-net
```
