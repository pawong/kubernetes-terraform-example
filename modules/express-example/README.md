# Express Example

Builds and deploys a simple Expres example, includes service and ingress.

Generated

```bash
% npx express-generator --view=pug
```

Initiated

```bash
% npm init
```

Start

```bash
% DEBUG=backend:* npm start
```

Run with NodeMon

```
% npm run dev
```

### Terraform Deploy

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
% docker save {image_name} > {image_name}.tar
% scp {image_name}.tar {username@hostname}:
# on host
% microk8s ctr image import {image_name}.tar
```

Then try to deploy again.
