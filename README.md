# Kubernetes-Terraform-Example

Kubernetes Terraform Example

## Secrets

No passwords live in this repo. Every credential is declared as a sensitive variable in
[variables.tf](variables.tf) with no default, so a missing value fails `terraform plan` rather than
quietly deploying a known password. Modules turn them into `kubernetes_secret_v1` resources and
containers read them through `secret_ref` / `secret_key_ref`.

Values go in `secrets.auto.tfvars`, which is untracked via the `*.tfvars` rule in `.gitignore`:

```bash
% cp secrets.auto.tfvars.example secrets.auto.tfvars
% $EDITOR secrets.auto.tfvars
```

Terraform picks up `*.auto.tfvars` automatically, so no `-var-file` flag is needed.

Two caveats worth knowing:

- `terraform.tfstate` stores these values in plaintext. It is gitignored, but treat the file as
  sensitive and do not copy it around.
- Kubernetes Secrets are base64, not encrypted, unless etcd encryption at rest is enabled. They keep
  credentials out of git and out of `kubectl describe`, which is the goal here.

To read one back:

```bash
% kubectl -n postgresql get secret postgresql-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d
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
```

## Connect to a pod

```bash
% kubectl -n <namespace> exec --stdin --tty <pod_name> -- /bin/bash
```

## Pre-Commits

Run manually:

```bash
% pre-commit run -a
```

## Deploy

```bash
% cd main
% tf apply
```
