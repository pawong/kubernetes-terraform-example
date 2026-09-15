# Observability Ingress

Access Prometheus

```bash
% kubectl port-forward -n observability service/prometheus-operated --address 0.0.0.0 9090:9090
```
