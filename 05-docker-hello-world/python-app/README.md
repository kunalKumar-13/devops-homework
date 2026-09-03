# Python Hello World (Flask)

A minimal **Flask** application serving a Hello World page.

| File | Purpose |
|---|---|
| `app.py` | the Flask app, bound to `0.0.0.0:5000` |
| `requirements.txt` | pins `flask==3.0.3` |
| `Dockerfile` | `python:3.12-slim` → `pip install -r requirements.txt` → `python app.py` |

**Dockerfile notes:** binding to `0.0.0.0` rather than `127.0.0.1` is essential — a
container that listens only on loopback is unreachable from outside, no matter what
`-p` says. `--no-cache-dir` keeps the pip cache out of the image.

## Build and run

```bash
cd python-app
docker build -t hello-python .
docker run -d --name python-hello -p 5100:5000 hello-python
```

Then open **http://localhost:5100**

## Real build and run output

```console
$ cd /Users/kunalpronto/personal/repos/devops-homework/05-docker-hello-world/python-app && docker build -t hello-python .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  4.096kB

Step 1/7 : FROM python:3.12-slim
 ---> 78387bc3881b
Step 2/7 : WORKDIR /app
 ---> Using cache
 ---> 377b1d9043eb
Step 3/7 : COPY requirements.txt ./
 ---> Using cache
 ---> f8aeb6b6eab7
Step 4/7 : RUN pip install --no-cache-dir -r requirements.txt
 ---> Using cache
 ---> d3203cb8018c
Step 5/7 : COPY app.py ./
 ---> Using cache
 ---> 91582ae4db3b
Step 6/7 : EXPOSE 5000
 ---> Using cache
 ---> 1545fece5366
Step 7/7 : CMD ["python", "app.py"]
 ---> Using cache
 ---> 63a444f871f2
Successfully built 63a444f871f2
Successfully tagged hello-python:latest

$ docker run -d --name python-hello -p 5100:5000 hello-python
e896025a0690078b91bb0565e40250330b73ddd659036d62ebf896cbd965d9b4

$ docker ps --filter name=python-hello --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES          IMAGE          STATUS         PORTS
python-hello   hello-python   Up 4 seconds   0.0.0.0:5100->5000/tcp, [::]:5100->5000/tcp
```

## Screenshot

![Python Hello World (Flask)](../screenshots/python-app.png)
