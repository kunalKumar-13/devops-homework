# Docker Multi-Stage Build Homework

**→ The graded submission document is [`submission.md`](submission.md)** (name,
enrollment number, and the screenshots/output evidence).

This README is the working notes: what a multi-stage build is, the Dockerfile used, and
the full build/run log.

## Folder contents

```
06-docker-multistage/
├── README.md            this file
├── submission.md        the submission document (name, enrolment no., evidence)
├── Dockerfile           the multi-stage Dockerfile
├── app/
│   ├── main.go          the web app: "Hello World from Docker multi-stage build"
│   └── go.mod
└── screenshots/
    └── app-running-8080.png
```

## What a multi-stage build is

A multi-stage Dockerfile has **more than one `FROM`**. Each `FROM` starts a new stage
with its own filesystem, and a later stage copies only the artifacts it needs with
`COPY --from=<stage>`. Everything else — compilers, SDKs, package caches, source code —
is discarded when the build ends.

```
┌─ Stage 1: builder ──────────────┐      ┌─ Stage 2: runtime ─────────┐
│ FROM golang:1.22-alpine         │      │ FROM alpine:3.20           │
│ full Go toolchain, source code  │ ───► │ COPY --from=builder ...    │
│ go build → /out/server          │ only │ just the binary            │
│ ~440 MB, thrown away            │ this │ 20.2 MB, shipped           │
└─────────────────────────────────┘      └────────────────────────────┘
```

**Why it matters**

| | Single stage | Multi-stage |
|---|---|---|
| Final image size (this app) | **440 MB** | **20.2 MB** — 21× smaller |
| Compiler in the image | yes | no |
| Source code in the image | yes | no |
| Attack surface | large | minimal |
| Pull / deploy time | slow | fast |

Smaller is not just about disk: every megabyte is downloaded on every deploy, scanned by
every security scanner, and is one more thing that can carry a CVE. A build toolchain in
a production image is a liability, not a feature.

## The Dockerfile

```dockerfile
# =========================================================
# Stage 1 — build
# A full Go toolchain (~800 MB) compiles the binary. None of
# this stage ends up in the final image.
# =========================================================
FROM golang:1.22-alpine AS builder

WORKDIR /src
COPY app/go.mod ./
COPY app/main.go ./

# CGO_ENABLED=0 produces a fully static binary, so the runtime
# stage does not need libc at all.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/server main.go

# =========================================================
# Stage 2 — runtime
# Only the compiled binary is copied across. The result is a
# few megabytes instead of several hundred.
# =========================================================
FROM alpine:3.20

RUN adduser -D -u 10001 appuser
COPY --from=builder /out/server /usr/local/bin/server

USER appuser
EXPOSE 8080

CMD ["/usr/local/bin/server"]
```

Two details worth calling out:

* **`CGO_ENABLED=0`** produces a fully static binary, so the runtime stage does not need
  libc at all — the image could even be `scratch` (empty) if it did not need a shell.
* **`USER appuser`** — the container does not run as root. Free to add, and it is what a
  reviewer looks for.

## Build, run and verify — full real output

```console
########## 1. The multi-stage Dockerfile ##########
$ cat Dockerfile
# =========================================================
# Stage 1 — build
# A full Go toolchain (~800 MB) compiles the binary. None of
# this stage ends up in the final image.
# =========================================================
FROM golang:1.22-alpine AS builder

WORKDIR /src
COPY app/go.mod ./
COPY app/main.go ./

# CGO_ENABLED=0 produces a fully static binary, so the runtime
# stage does not need libc at all.
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/server main.go

# =========================================================
# Stage 2 — runtime
# Only the compiled binary is copied across. The result is a
# few megabytes instead of several hundred.
# =========================================================
FROM alpine:3.20

RUN adduser -D -u 10001 appuser
COPY --from=builder /out/server /usr/local/bin/server

USER appuser
EXPOSE 8080

CMD ["/usr/local/bin/server"]

########## 2. Build the image from the multi-stage Dockerfile ##########
$ docker build -t multistage-hello .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  5.632kB
Step 1/11 : FROM golang:1.22-alpine AS builder
1.22-alpine: Pulling from library/golang
52f827f72350: Pulling fs layer
fa1868c9f11e: Pulling fs layer
4f4fb700ef54: Pulling fs layer
90fc70e12d60: Pulling fs layer
4861bab1ea04: Pulling fs layer
4f4fb700ef54: Already exists
4861bab1ea04: Download complete
52f827f72350: Download complete
fa1868c9f11e: Download complete
52f827f72350: Pull complete
fa1868c9f11e: Pull complete
d8f26b50cb63: Download complete
90beb63ddd6e: Download complete
90fc70e12d60: Download complete
4f4fb700ef54: Pull complete
4861bab1ea04: Pull complete
90fc70e12d60: Pull complete
Digest: sha256:1699c10032ca2582ec89a24a1312d986a3f094aed3d5c1147b19880afe40e052
Status: Downloaded newer image for golang:1.22-alpine
 ---> 1699c10032ca
Step 2/11 : WORKDIR /src
 ---> Running in d31bce59e834
 ---> Removed intermediate container d31bce59e834
 ---> 0680dc6fe737
Step 3/11 : COPY app/go.mod ./
 ---> 29c0538c4baf
Step 4/11 : COPY app/main.go ./
 ---> 3a03494dadd1
Step 5/11 : RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/server main.go
 ---> Running in 43b39877bff1
 ---> Removed intermediate container 43b39877bff1
 ---> b84395eb2d89
Step 6/11 : FROM alpine:3.20
3.20: Pulling from library/alpine
3f26bc2dec0b: Pulling fs layer
3f26bc2dec0b: Download complete
3f26bc2dec0b: Pull complete
8b093306b817: Download complete
cee42a41056b: Download complete
Digest: sha256:d9e853e87e55526f6b2917df91a2115c36dd7c696a35be12163d44e6e2a4b6bc
Status: Downloaded newer image for alpine:3.20
 ---> d9e853e87e55
Step 7/11 : RUN adduser -D -u 10001 appuser
 ---> Running in f830eaa064d4
 ---> Removed intermediate container f830eaa064d4
 ---> 859b230ec023
Step 8/11 : COPY --from=builder /out/server /usr/local/bin/server
 ---> bca5c7e3e83a
Step 9/11 : USER appuser
 ---> Running in 78f084162ea4
 ---> Removed intermediate container 78f084162ea4
 ---> 256e01ab9c71
Step 10/11 : EXPOSE 8080
 ---> Running in cbd5b825451f
 ---> Removed intermediate container cbd5b825451f
 ---> 330d2fc1ebe8
Step 11/11 : CMD ["/usr/local/bin/server"]
 ---> Running in 641320fa07ab
 ---> Removed intermediate container 641320fa07ab
 ---> 4c1dd38b7f97
Successfully built 4c1dd38b7f97
Successfully tagged multistage-hello:latest

########## 3. Run a container from the image on port 8080 ##########
$ docker run -d --name multistage-app -p 8080:8080 multistage-hello
41cfc184ebef8d74e5468f3fe70dba4c4597aa691f4eaab16c99437e93190f1a

########## 4. Verify the container with docker ps (port 8080) ##########
$ docker ps
CONTAINER ID   IMAGE              COMMAND                  CREATED         STATUS         PORTS                                         NAMES
41cfc184ebef   multistage-hello   "/usr/local/bin/serv…"   3 seconds ago   Up 3 seconds   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp   multistage-app
fa3f2989dbe7   hello-nginx        "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes   0.0.0.0:8182->80/tcp, [::]:8182->80/tcp       nginx-hello
a8dc60743599   hello-react        "/docker-entrypoint.…"   4 minutes ago   Up 4 minutes   0.0.0.0:3101->80/tcp, [::]:3101->80/tcp       react-hello
9fd608271eda   hello-apache       "httpd-foreground"       4 minutes ago   Up 4 minutes   0.0.0.0:8181->80/tcp, [::]:8181->80/tcp       apache-hello
6a7d47082ef9   hello-java         "/__cacert_entrypoin…"   4 minutes ago   Up 4 minutes   0.0.0.0:8180->8080/tcp, [::]:8180->8080/tcp   java-hello
e896025a0690   hello-python       "python app.py"          4 minutes ago   Up 4 minutes   0.0.0.0:5100->5000/tcp, [::]:5100->5000/tcp   python-hello
f74b1208b211   hello-nodejs       "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes   0.0.0.0:3100->3000/tcp, [::]:3100->3000/tcp   node-hello

$ docker ps --filter name=multistage-app --format 'table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Names}}'
CONTAINER ID   IMAGE              STATUS         PORTS                                         NAMES
41cfc184ebef   multistage-hello   Up 3 seconds   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp   multistage-app

########## 5. Access the application ##########
$ curl -s http://localhost:8080/health
Hello World from Docker multi-stage build

$ curl -s http://localhost:8080
<!doctype html>
<html>
  <head><title>Multi-stage build</title></head>
  <body style="font-family: system-ui, sans-serif; text-align: center; padding-top: 80px;">
    <h1>Hello World from Docker multi-stage build</h1>
  </body>
</html>
$ curl -s -o /dev/null -w 'HTTP status: %{http_code}\n' http://localhost:8080
HTTP status: 200

########## 6. Container logs ##########
$ docker logs multistage-app
2026/09/03 15:24:57 listening on :8080

########## 7. Why multi-stage matters — image size comparison ##########
Build the SAME app with a single-stage Dockerfile for comparison:
$ cat /tmp/Dockerfile.singlestage
FROM golang:1.22-alpine
WORKDIR /src
COPY app/go.mod ./
COPY app/main.go ./
RUN CGO_ENABLED=0 go build -o /usr/local/bin/server main.go
EXPOSE 8080
CMD ["/usr/local/bin/server"]

$ docker build -f /tmp/Dockerfile.singlestage -t singlestage-hello . | tail -n 3
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

 ---> c7b02257755b
Successfully built c7b02257755b
Successfully tagged singlestage-hello:latest

$ docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' | grep -E 'REPOSITORY|stage-hello'
REPOSITORY          TAG           SIZE
singlestage-hello   latest        440MB
multistage-hello    latest        20.2MB

$ docker history multistage-hello
IMAGE          CREATED         CREATED BY                                      SIZE      COMMENT
4c1dd38b7f97   8 seconds ago   /bin/sh -c #(nop)  CMD ["/usr/local/bin/serv…   0B        
330d2fc1ebe8   8 seconds ago   /bin/sh -c #(nop)  EXPOSE 8080                  0B        
256e01ab9c71   8 seconds ago   /bin/sh -c #(nop)  USER appuser                 0B        
bca5c7e3e83a   9 seconds ago   /bin/sh -c #(nop) COPY file:14848e78bef18a6a…   4.61MB    
859b230ec023   9 seconds ago   /bin/sh -c adduser -D -u 10001 appuser          41kB      
d9e853e87e55   4 months ago    CMD ["/bin/sh"]                                 0B        buildkit.dockerfile.v0
<missing>      4 months ago    ADD alpine-minirootfs-3.20.10-aarch64.tar.gz…   9.49MB    buildkit.dockerfile.v0

```

## Reading `docker history`

The final image is seven layers, and the interesting ones are:

```
ADD alpine-minirootfs-3.20.10-aarch64.tar.gz     9.49MB    ← the Alpine base
adduser -D -u 10001 appuser                        41kB    ← the non-root user
COPY file:14848e78bef18a6a... (--from=builder)    4.61MB   ← the compiled binary
```

`4.61 MB` is the entire application. **The Go toolchain from stage 1 does not appear at
all** — that is the multi-stage build doing its job.

## Task 3 — deploying more application types with Docker

Required: at least three. **Six** were built and run, in
[`../05-docker-hello-world/`](../05-docker-hello-world/) — Node.js, Python, Java,
Apache, React and Nginx, each with its own Dockerfile, all verified in a browser.
Two of those (Java and React) are themselves multi-stage builds.
