# GoLang Example

### Run locally

```bash
% go run .
```

## The real build/issue issue

The image is getting build and pushed to docker locally, however the deploy is trying to pull from some repository in the sky (most likely `docker.io`). This is causing the pull to fail and just have some bad html in it. I haven't found a good way to use docker as a repository.

This is the documentation, <https://microk8s.io/docs/registry-images>.

TL;DR

```bash
% docker build . -t library/go-example-image:latest --platform linux/arm64 # check your deployment platform
% docker save library/go-example-image:latest > go-example-image.tar
% scp go-example-image.tar {username@hostname}:
# on host
% microk8s ctr image import go-example-image.tar
```

Then try to deploy again.
