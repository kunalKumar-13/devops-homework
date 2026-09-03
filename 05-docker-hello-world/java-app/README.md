# Java Hello World (JDK HttpServer)

A Hello World web server built on the JDK's own `com.sun.net.httpserver.HttpServer`,
so the image needs no Maven, Gradle or third-party dependency.

| File | Purpose |
|---|---|
| `HelloWorld.java` | the server, listening on port 8080 |
| `Dockerfile` | two stages: compile with the **JDK**, run on the **JRE** |

**Dockerfile notes:** this is already a small multi-stage build — `eclipse-temurin:21-jdk`
compiles the class, and only the compiled output is copied into
`eclipse-temurin:21-jre`, so the compiler never ships in the final image.

## Build and run

```bash
cd java-app
docker build -t hello-java .
docker run -d --name java-hello -p 8180:8080 hello-java
```

Then open **http://localhost:8180**

## Real build and run output

```console
$ cd /Users/kunalpronto/personal/repos/devops-homework/05-docker-hello-world/java-app && docker build -t hello-java .
DEPRECATED: The legacy builder is deprecated and will be removed in a future release.
            Install the buildx component to build images with BuildKit:
            https://docs.docker.com/go/buildx/

Sending build context to Docker daemon  4.096kB

Step 1/9 : FROM eclipse-temurin:21-jdk AS build
 ---> 85f00967bcc6
Step 2/9 : WORKDIR /src
 ---> Using cache
 ---> 1386fee093ed
Step 3/9 : COPY HelloWorld.java ./
 ---> Using cache
 ---> 79e209db3ad7
Step 4/9 : RUN javac -d /out HelloWorld.java
 ---> Using cache
 ---> a346d7670343
Step 5/9 : FROM eclipse-temurin:21-jre
 ---> 7a65df4b22d2
Step 6/9 : WORKDIR /app
 ---> Using cache
 ---> ef458ec08d23
Step 7/9 : COPY --from=build /out ./
 ---> Using cache
 ---> 6a605e54f957
Step 8/9 : EXPOSE 8080
 ---> Using cache
 ---> 277fdc128b6a
Step 9/9 : CMD ["java", "HelloWorld"]
 ---> Using cache
 ---> 9fdf3ca8f66c
Successfully built 9fdf3ca8f66c
Successfully tagged hello-java:latest

$ docker run -d --name java-hello -p 8180:8080 hello-java
6a7d47082ef9585bce285d30f5a14a0b87d9ca11c0611683cd36ed9bc50a6a0b

$ docker ps --filter name=java-hello --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
NAMES        IMAGE        STATUS         PORTS
java-hello   hello-java   Up 4 seconds   0.0.0.0:8180->8080/tcp, [::]:8180->8080/tcp
```

## Screenshot

![Java Hello World (JDK HttpServer)](../screenshots/java-app.png)
