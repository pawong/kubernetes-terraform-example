# FastAPI Example

Builds and deploys a simple FastAPI example, includes service and ingress.

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
% docker build -t library/fastapi-example-image:latest --platform linux/arm64 --build-arg GIT_COMMIT=$(git rev-parse --short HEAD) . # check your deployment platform
% docker save library/fastapi-example-image:latest > fastapi-example-image.tar
% scp fastapi-example-image.tar {username@hostname}:
# on host
% microk8s ctr image import fastapi-example-image.tar
```

Then try to deploy again.
