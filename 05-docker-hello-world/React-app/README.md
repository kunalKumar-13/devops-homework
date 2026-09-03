# React Hello World (Vite + Nginx)

A real **React** application built with **Vite** and served as a static bundle by Nginx.

| File | Purpose |
|---|---|
| `src/App.jsx` | the React component that renders *Hello World from React* |
| `src/main.jsx` | mounts the app into `#root` |
| `index.html`, `vite.config.js` | the Vite entry point and config |
| `package.json` | React 18 + Vite |
| `Dockerfile` | **multi-stage**: build with Node, serve with Nginx |

**Dockerfile notes:** this is the standard production pattern for a front-end app. Stage
one runs `npm install && npm run build` on `node:20-alpine` and produces `/app/dist`;
stage two copies only `dist` into `nginx:alpine`. Node and `node_modules` never reach
the final image — which is why it ends up at **102 MB** instead of several hundred.

**Note on verification:** `curl` returns the empty HTML shell because the heading is
rendered by JavaScript in the browser. The screenshot below is the real proof that the
page displays Hello World.

## Build and run

```bash
cd React-app
docker build -t hello-react .
docker run -d --name react-hello -p 3101:80 hello-react
```

Then open **http://localhost:3101**

## Real build and run output

```console
$ cd /Users/kunalpronto/personal/repos/devops-homework/05-docker-hello-world/React-app && docker build -t hello-react .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  9.728kB

Step 1/9 : FROM node:20-alpine AS build
 ---> fb4cd12c85ee
Step 2/9 : WORKDIR /app
 ---> Using cache
 ---> a7811b9699d5
Step 3/9 : COPY package.json ./
 ---> Using cache
 ---> 8db51bcc8f87
Step 4/9 : RUN npm install
 ---> Using cache
 ---> fb4c786bd7e1
Step 5/9 : COPY . .
 ---> Using cache
 ---> e3b6edf3f088
Step 6/9 : RUN npm run build
 ---> Using cache
 ---> 34f7e5ab0872
Step 7/9 : FROM nginx:alpine
 ---> a9ae6f6d078d
Step 8/9 : COPY --from=build /app/dist /usr/share/nginx/html
 ---> Using cache
 ---> 7097f8741e8b
Step 9/9 : EXPOSE 80
 ---> Using cache
 ---> a88bda038bcc
Successfully built a88bda038bcc
Successfully tagged hello-react:latest

$ docker run -d --name react-hello -p 3101:80 hello-react
a8dc60743599de7b981b2a48d445950aadbd2b985371b098027dd20b00c05298

$ docker ps --filter name=react-hello --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES         IMAGE         STATUS         PORTS
react-hello   hello-react   Up 4 seconds   0.0.0.0:3101->80/tcp, [::]:3101->80/tcp
```

## Screenshot

![React Hello World (Vite + Nginx)](../screenshots/React-app.png)
