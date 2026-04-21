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

### Issues

#### Password

The default password requires `scram-sha-256`, but on creation it sets it to something else. Also we need to add our network range to the `pg_hba.conf` file. Edit the file and add `host all all 192.168.10.0/24 trust`.

Login and change the postgres password,

```
pwong@jessica:~                                                                                                                                     [11:30:49]
$ psql -h jessica -p 30032 -U postgres
postgres=# ALTER USER postgres WITH PASSWORD 'passord';
ALTER ROLE
postgres=# SELECT pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)

postgres=#
```

Then edit the `pg_hba.conf` file again and change the previous line to `host all all 192.168.10.0/24 scram-sha-256`.
Reload config file,

```
pwong@jessica:~                                                                                                                                     [11:30:49]
$ psql -h jessica -p 30032 -U postgres
postgres=# SELECT pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)

```

Done.
