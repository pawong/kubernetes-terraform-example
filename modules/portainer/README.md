# Portainer

Enable Portainer on Microk8s

```bash
% microk8s enable portainer
```

### Services

- portainer

### Ingress

Create the ingress to port 30779

Adding a default backend to the ingress will force anythin like `portainer.example.com` to that service.
