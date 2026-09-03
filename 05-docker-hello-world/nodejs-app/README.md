# Node.js Hello World (Express)

A minimal **Express** server that responds with a Hello World page.

| File | Purpose |
|---|---|
| `server.js` | the Express app, listening on port 3000 |
| `package.json` | declares the `express` dependency and the `start` script |
| `Dockerfile` | `node:20-alpine` → `npm install` → `node server.js` |
| `.dockerignore` | keeps `node_modules` out of the build context |

**Dockerfile notes:** `package.json` is copied *before* the source so the
`npm install` layer is cached and only re-runs when dependencies change.
`--omit=dev` skips devDependencies in the image.

## Build and run

```bash
cd nodejs-app
docker build -t hello-nodejs .
docker run -d --name node-hello -p 3100:3000 hello-nodejs
```

Then open **http://localhost:3100**

## Real build and run output

```console
$ cd /Users/kunalpronto/personal/repos/devops-homework/05-docker-hello-world/nodejs-app && docker build -t hello-nodejs .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  5.632kB

Step 1/7 : FROM node:20-alpine
 ---> fb4cd12c85ee
Step 2/7 : WORKDIR /app
 ---> Using cache
 ---> a7811b9699d5
Step 3/7 : COPY package.json ./
 ---> Using cache
 ---> e11c6887e99b
Step 4/7 : RUN npm install --omit=dev
 ---> Using cache
 ---> e35bf1e4b1ca
Step 5/7 : COPY server.js ./
 ---> Using cache
 ---> ffbd672d5dd9
Step 6/7 : EXPOSE 3000
 ---> Using cache
 ---> 37e49d5dc291
Step 7/7 : CMD ["node", "server.js"]
 ---> Using cache
 ---> 250b2d493df9
Successfully built 250b2d493df9
Successfully tagged hello-nodejs:latest

$ docker run -d --name node-hello -p 3100:3000 hello-nodejs
f74b1208b21138cd7986b1cd6e5fe6b1b9c75e326af427cedfb8ba81dba65f8b

$ docker ps --filter name=node-hello --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES        IMAGE          STATUS         PORTS
node-hello   hello-nodejs   Up 4 seconds   0.0.0.0:3100->3000/tcp, [::]:3100->3000/tcp
```

## Screenshot

![Node.js Hello World (Express)](../screenshots/nodejs-app.png)
