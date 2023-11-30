# Kubernetes-Terraform-Example

Kubernetes Terraform Example

### Host File

Add `example.com` to your host file.

```
192.168.10.xx   example.com
192.168.10.xx   apple.example.com
192.168.10.xx   banana.example.com
192.168.10.xx   nginx.example.com
```

### Connect to a pod

```
% kubectl -n <namespace> exec --stdin --tty <pod_name> -- /bin/bash
```
