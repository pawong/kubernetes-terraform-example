# couchbase

Single node [Couchbase Server](https://www.couchbase.com/) deployment.

## Version

Defaults to `couchbase:community-7.6.2`, **not** the newer 8.0 line. Couchbase
Server 8.0 refuses to start unless the CPU is x86-64-v3:

```
Aborting! Couchbase Server requires x86_64 CPU microarchitecture v3 or higher (found v2).
```

Check before bumping `couchbase_image` to `community-8.0.2`:

```bash
% grep -o 'avx2' /proc/cpuinfo | head -1   # on the node - empty means v2, so stay on 7.6
```

Enterprise builds (`couchbase:enterprise-8.0.3`) need a licence for anything
other than development/testing.

Startup logs a warning that the open file limit is 65536 rather than the
recommended 200000. It is inherited from the container runtime and is not fatal
for a single-node dev cluster.

Couchbase persists its node name in the on-disk config, so the server runs as a
`StatefulSet` (stable `couchbase-0` hostname) backed by a static hostPath
`PersistentVolume` at `<host_data_directory>/couchbase`.

A container starts unconfigured, so a `couchbase-init` Job waits for port 8091,
runs `couchbase-cli cluster-init` and creates the first bucket. Both steps are
skipped if the cluster/bucket already exists, so re-applying is safe.

## Endpoints

| Service | Port  | NodePort |
| ------- | ----- | -------- |
| Admin / REST / Web UI | 8091 | 30891 |
| Views | 8092 | 30892 |
| Query (N1QL) | 8093 | 30893 |
| Search | 8094 | 30894 |
| Data (KV) | 11210 | 31210 |

The Web UI is also exposed through an ingress at
`<subdomain_name>.<domain_name>` (default `couchbase.example.com`).

In-cluster connection string: `couchbase://couchbase.couchbase.svc.cluster.local`

## Usage

```hcl
module "couchbase" {
  source             = "./modules/couchbase"
  couchbase_password = var.couchbase_password
}
```

`couchbase_password` has no default - set it in the root `secrets.auto.tfvars`. It becomes the
`couchbase-secret` Opaque Secret, which both the server and the init Job read through `secret_ref`.

## Check the cluster

```bash
% kubectl -n couchbase logs job/couchbase-init
% kubectl -n couchbase exec -it couchbase-0 -- \
    couchbase-cli server-list -c localhost:8091 -u Administrator -p password
```
