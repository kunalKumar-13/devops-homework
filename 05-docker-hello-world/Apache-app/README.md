# Apache Hello World (httpd)

A static Hello World page served by the **Apache HTTP Server**.

| File | Purpose |
|---|---|
| `index.html` | the page |
| `Dockerfile` | `httpd:2.4` with `index.html` copied into `/usr/local/apache2/htdocs/` |

**Dockerfile notes:** the official `httpd` image already starts Apache in the
foreground, so no `CMD` is needed — the whole Dockerfile is a `FROM` and a `COPY`.
Apache's document root inside this image is `/usr/local/apache2/htdocs`.

## Build and run

```bash
cd Apache-app
docker build -t hello-apache .
docker run -d --name apache-hello -p 8181:80 hello-apache
```

Then open **http://localhost:8181**

## Real build and run output

```console
$ cd /Users/kunalpronto/personal/repos/devops-homework/05-docker-hello-world/Apache-app && docker build -t hello-apache .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  3.072kB

Step 1/3 : FROM httpd:2.4
 ---> 979c38c2228d
Step 2/3 : COPY index.html /usr/local/apache2/htdocs/index.html
 ---> Using cache
 ---> 83645e20d5d1
Step 3/3 : EXPOSE 80
 ---> Using cache
 ---> 44d471eda451
Successfully built 44d471eda451
Successfully tagged hello-apache:latest

$ docker run -d --name apache-hello -p 8181:80 hello-apache
9fd608271edafc0f522992c70812c71b6bf90e645d8f3a91b13556adcc028dd6

$ docker ps --filter name=apache-hello --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES          IMAGE          STATUS         PORTS
apache-hello   hello-apache   Up 4 seconds   0.0.0.0:8181->80/tcp, [::]:8181->80/tcp
```

## Screenshot

![Apache Hello World (httpd)](../screenshots/Apache-app.png)
