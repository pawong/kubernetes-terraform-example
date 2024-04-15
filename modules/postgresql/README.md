# PostgreSQL

## Client

### Direct

```bash
% k exec -it postgresql-deployment-6487bfc987-v2vwf -- psql -U postgres
```

### Pod

```bash
% kubectl run postgresql-postgresql-client --rm --tty -i --restart='Never' --namespace default --image bitnami/postgresql --env="PGPASSWORD=changeme" --command -- psql --host postgresql-service.postgresql.svc.cluster.local -U postgres
```
