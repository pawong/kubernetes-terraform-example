# Kubernetes-Terraform-Example

Kubernetes Terraform Example

## Host File

Add `example.com` to your host file.

```bash
192.168.10.xx   example.com
192.168.10.xx   ingress.example.com
192.168.10.xx   nginx.example.com
192.168.10.xx   fastapi.example.com
192.168.10.xx   express.example.com
192.168.10.xx   kotlin.example.com
```

## Connect to a pod

```bash
% kubectl -n <namespace> exec --stdin --tty <pod_name> -- /bin/bash
```
