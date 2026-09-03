# Nginx Hello World

A static Hello World page served by **Nginx**.

| File | Purpose |
|---|---|
| `index.html` | the page |
| `Dockerfile` | `nginx:alpine` with `index.html` copied into `/usr/share/nginx/html/` |

**Dockerfile notes:** the Alpine variant keeps the image at ~102 MB. Nginx's document
root in this image is `/usr/share/nginx/html`, and the base image already runs nginx in
the foreground, so again no `CMD` is required.

## Build and run

```bash
cd nginx-app
docker build -t hello-nginx .
docker run -d --name nginx-hello -p 8182:80 hello-nginx
```

Then open **http://localhost:8182**

## Real build and run output

```console
$ cd /Users/kunalpronto/personal/repos/devops-homework/05-docker-hello-world/nginx-app && docker build -t hello-nginx .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  3.072kB

Step 1/3 : FROM nginx:alpine
 ---> a9ae6f6d078d
Step 2/3 : COPY index.html /usr/share/nginx/html/index.html
 ---> Using cache
 ---> aa20d82d9d11
Step 3/3 : EXPOSE 80
 ---> Using cache
 ---> c2a2fc84c17f
Successfully built c2a2fc84c17f
Successfully tagged hello-nginx:latest

$ docker run -d --name nginx-hello -p 8182:80 hello-nginx
fa3f2989dbe7afaa9c688ce58680172e10337451a3ce90ed154e599d71214ecc

$ docker ps --filter name=nginx-hello --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES         IMAGE         STATUS         PORTS
nginx-hello   hello-nginx   Up 4 seconds   0.0.0.0:8182->80/tcp, [::]:8182->80/tcp
```

## Screenshot

![Nginx Hello World](../screenshots/nginx-app.png)
