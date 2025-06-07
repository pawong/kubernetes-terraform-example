# Kotlin Example

Builds and deploys a simple Kotlin Example, includes service and ingress.

For a quick start, backend servers can use [**Ktor Project Generator**](https://start.ktor.io/#/settings?name=kotlin-example&website=example.com&artifact=com.example.kotlin-example&kotlinVersion=1.9.22&ktorVersion=2.3.7&buildSystem=GRADLE_KTS&engine=NETTY&configurationIn=CODE&addSampleCode=true&plugins=).

Using local Docker for building.

```javascript
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

## The real build/issue issue

The image is getting build and pushed to docker locally, however the deploy is trying to pull from some repository in the sky (most likely `docker.io`). This is causing the pull to fail and just have some bad html in it. I haven't found a good way to use docker as a repository.

This is the documentation, <https://microk8s.io/docs/registry-images>.

TL;DR

```bash
# check your deployment platform
% docker build . -t library/fastapi-example-image:latest --platform linux/arm64 --build-arg GIT_COMMIT=$(git rev-parse --short HEAD)
% docker save library/kotlin-example-image:latest > kotlin-example-image.tar
% scp kotlin-example-image.tar {username@hostname}:
# on host
% microk8s ctr image import kotlin-example-image.tar
```

Then try to deploy again.

## Build and Run on workstation

From the build directory...

```bash
% ./gradlew build
% ./gradlew run
```

## Build and Run the Docker Image

From the build directory...

```bash
% docker build -t library/kotlin-example-image:latest . && docker run -p 8080:8080 library/kotlin-example-image
```
