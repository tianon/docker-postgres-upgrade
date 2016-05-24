# `pg_upgrade`, Docker style

Tags of this image are of the format `OLD-to-NEW`, where `OLD` represents the version of PostgreSQL you are _currently_ running, and `NEW` represents the version of PostgreSQL you would like to upgrade to.

In order to get good performance, it is recommended to run this image with `docker run image --link` (see [`pg_upgrade` documentation](https://www.postgresql.org/docs/9.5/static/pgupgrade.html) for more details).

For this to be feasible, your directory structure should look something like this: (if yours does not, either adjust it, or scroll down to see the alternate pattern for running this image)

```console
$ find DIR -mindepth 2 -maxdepth 2
DIR/OLD/data
DIR/NEW/data

$ docker run --rm \
	-v DIR:/var/lib/postgresql \
	tianon/postgres-upgrade:OLD-to-NEW \
	--link

...
```

More concretely, assuming `OLD` of `9.4`, `NEW` of `9.5`, and `DIR` of `/mnt/bigdrive/postgresql`:

```console
$ find /mnt/bigdrive/postgresql -mindepth 2 -maxdepth 2
/mnt/bigdrive/postgresql/9.4/data
/mnt/bigdrive/postgresql/9.5/data

$ docker run --rm \
	-v /mnt/bigdrive/postgresql:/var/lib/postgresql \
	tianon/postgres-upgrade:9.4-to-9.5 \
	--link

...
```

(which assumes that your previous `postgres:9.4` instance was running with `-v /mnt/bigdrive/postgresql/9.4/data:/var/lib/postgresql/data`, and your new `postgres:9.5` instance will run with `-v /mnt/bigdrive/postgresql/9.5/data:/var/lib/postgresql/data`)

---

If your two directories (denoted below as `PGDATAOLD` and `PGDATANEW`) do not follow this structure, then the following may also be used (but will be slower):

```console
$ docker run --rm \
	-v PGDATAOLD:/var/lib/postgresql/OLD/data \
	-v PGDATANEW:/var/lib/postgresql/NEW/data \
	tianon/postgres-upgrade:OLD-to-NEW

...
```

More concretely, assuming `OLD` of `9.4`, `NEW` of `9.5`, `PGDATAOLD` of `/mnt/bigdrive/postgresql-9.4`, and `PGDATANEW` of `/mnt/bigdrive/postgresql-9.5`:

```console
$ docker run --rm \
	-v /mnt/bigdrive/postgresql-9.4:/var/lib/postgresql/9.4/data \
	-v /mnt/bigdrive/postgresql-9.5:/var/lib/postgresql/9.5/data \
	tianon/postgres-upgrade:9.4-to-9.5

...
```

(which assumes that your previous `postgres:9.4` instance was running with `-v /mnt/bigdrive/postgresql-9.4:/var/lib/postgresql/data`, and your new `postgres:9.5` instance will run with `-v /mnt/bigdrive/postgresql-9.5:/var/lib/postgresql/data`)
