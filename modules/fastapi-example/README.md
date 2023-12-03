# fastapi-example

Builds and deploys a simple FastAPI example, includes service and ingress.

Using local Docker for building.

```javascript
provider "docker" {
  host = "unix:///var/run/docker.sock"
}
```

Image build example.

```javascript
resource "docker_image" "fastapi_example_image" {
  name = "${var.module_name}/${var.module_name}-example-image"
  build {
    context = "${path.module}/backend"
    tag     = ["${var.module_name}/${var.module_name}-example-image:latest"]
    build_arg = {
      name : "${var.module_name}/${var.module_name}-example-image"
    }
    label = {
      author : "me@nowhere.com"
    }
  }
}
```

*Note: `"${path.module}/backend"`, is the location of the `Dockerfile`. Local references will fail to build. Terraform will complain about missing temp files.*
