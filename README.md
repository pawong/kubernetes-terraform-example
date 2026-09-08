# Kubernetes-Terraform-Example

Kubernetes Terraform Example

## Secrets

No passwords live in this repo. Every credential is declared as a sensitive variable in
[variables.tf](variables.tf) with no default, so a missing value fails `terraform plan` rather than
quietly deploying a known password. Modules turn them into `kubernetes_secret_v1` resources and
containers read them through `secret_ref` / `secret_key_ref`.

Values go in `secrets.auto.tfvars`, which is untracked via the `*.tfvars` rule in `.gitignore`:

```bash
cp secrets.auto.tfvars.example secrets.auto.tfvars
$EDITOR secrets.auto.tfvars
```

Terraform picks up `*.auto.tfvars` automatically, so no `-var-file` flag is needed.

Two caveats worth knowing:

- `terraform.tfstate` stores these values in plaintext. It is gitignored, but treat the file as
  sensitive and do not copy it around.
- Kubernetes Secrets are base64, not encrypted, unless etcd encryption at rest is enabled. They keep
  credentials out of git and out of `kubectl describe`, which is the goal here.

To read one back:

```bash
kubectl -n postgresql get secret postgresql-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d
```

Note that PostgreSQL and MongoDB only read their password variable on first start, when the data
directory is empty. Changing the value later updates the Secret but not the database, so rotate
inside the running server (`ALTER USER` / `db.changeUserPassword`) and keep the two in step.

## Host File

Add `example.com` to your host file.

```bash
192.168.10.xx   example.com
192.168.10.xx   ingress.example.com
192.168.10.xx   nginx.example.com
192.168.10.xx   fastapi.example.com
192.168.10.xx   express.example.com
192.168.10.xx   kotlin.example.com
192.168.10.xx   go.example.com
192.168.10.xx   couchbase.example.com
192.168.10.xx   portainer.example.com
```

## URLs

Hostnames come from the `subdomain_name` / `domain_name` arguments in [main.tf](main.tf), so these
are the defaults. Everything is plain HTTP - no ingress declares a `tls` block.

### Ingress

| Site             | URL                                                                     | Service port |
| ---------------- | ----------------------------------------------------------------------- | ------------ |
| nginx            | <http://nginx.example.com>                                              | 8080         |
| ingress example  | <http://ingress.example.com/apple>, <http://ingress.example.com/banana> | 5678         |
| FastAPI example  | <http://fastapi.example.com>                                            | 8080         |
| Express example  | <http://express.example.com>                                            | 3000         |
| Kotlin example   | <http://kotlin.example.com>                                             | 8080         |
| Go example       | <http://go.example.com>                                                 | 8080         |
| Couchbase Web UI | <http://couchbase.example.com>                                          | 8091         |
| Portainer        | <http://portainer.example.com>                                          | 9000         |

The four language examples also answer on `/health`, which is what their readiness and liveness
probes hit.

The Portainer module only creates the ingress. It expects a `portainer` service already running in
the `portainer` namespace (installed outside this repo), so the URL 503s until that exists.

### NodePort

Reachable at the node IP without a host file entry.

| Service                         | Port  | URL                                |
| ------------------------------- | ----- | ---------------------------------- |
| Couchbase admin / REST / Web UI | 8091  | <http://192.168.10.xx:30891>       |
| Couchbase views                 | 8092  | <http://192.168.10.xx:30892>       |
| Couchbase query (N1QL)          | 8093  | <http://192.168.10.xx:30893>       |
| Couchbase search (FTS)          | 8094  | <http://192.168.10.xx:30894>       |
| Couchbase data (KV)             | 11210 | `couchbase://192.168.10.xx:31210`  |
| DynamoDB Local                  | 8000  | <http://192.168.10.xx:30800>       |
| MongoDB                         | 27017 | `mongodb://192.168.10.xx:32017`    |
| PostgreSQL                      | 5432  | `postgresql://192.168.10.xx:30032` |

`couchbase_services` defaults to `data,index,query`, so port 8094 is published but nothing listens
on it until `fts` is added to that list.

### In-cluster

| Service        | Address                                                             |
| -------------- | ------------------------------------------------------------------- |
| Couchbase      | `couchbase://couchbase.couchbase.svc.cluster.local`                 |
| MongoDB        | `mongodb://mongodb.mongodb.svc.cluster.local:27017`                 |
| PostgreSQL     | `postgresql://postgresql-service.postgresql.svc.cluster.local:5432` |
| DynamoDB Local | `http://dynamodb-service.dynamodb.svc.cluster.local:8000`           |

## Connect to a pod

```bash
kubectl -n <namespace> exec --stdin --tty <pod_name> -- /bin/bash
```

## Pre-Commits

Run manually:

```bash
pre-commit run -a
```

## Deploy

```bash
cd main
tf apply
```
