# `pg_upgrade`, Docker style

This is a PoC for using `pg_upgrade` inside Docker -- learn from it, adapt it for your needs; don't expect it to work as-is!

(Source for this image is available at [https://github.com/tianon/docker-postgres-upgrade](https://github.com/tianon/docker-postgres-upgrade).)

Tags of this image are of the format `OLD-to-NEW`, where `OLD` represents the version of PostgreSQL you are _currently_ running, and `NEW` represents the version of PostgreSQL you would like to upgrade to.

In order to get good performance, it is recommended to run this image with `docker run image --link` (see [`pg_upgrade` documentation](https://www.postgresql.org/docs/18/pgupgrade.html) for more details).

For this to be feasible, your directory structure should look something like this: (if yours does not, either adjust it, or scroll down to see the alternate pattern for running this image)

```console
$ find DIR -mindepth 2 -maxdepth 2
DIR/OLD/docker
DIR/NEW/docker

$ docker run --rm \
	--mount 'type=bind,src=DIR,dst=/var/lib/postgresql' \
	--env 'PGDATAOLD=/var/lib/postgresql/OLD/docker' \
	--env 'PGDATANEW=/var/lib/postgresql/NEW/docker' \
	tianon/postgres-upgrade:OLD-to-NEW \
	--link

...
```

More concretely, assuming `OLD` of `17`, `NEW` of `18`, and `DIR` of `/mnt/bigdrive/postgresql`:

```console
$ find /mnt/bigdrive/postgresql -mindepth 2 -maxdepth 2
/mnt/bigdrive/postgresql/17/docker
/mnt/bigdrive/postgresql/18/docker

$ docker run --rm \
	--mount 'type=bind,src=/mnt/bigdrive/postgresql,dst=/var/lib/postgresql' \
	--env 'PGDATAOLD=/var/lib/postgresql/17/docker' \
	--env 'PGDATANEW=/var/lib/postgresql/18/docker' \
	tianon/postgres-upgrade:17-to-18 \
	--link

...
```

(as in, your previous `postgres:17` instance was running with `-v /mnt/bigdrive/postgresql/17/docker:/var/lib/postgresql/data`, and your new `postgres:18` instance will run with `-v /mnt/bigdrive/postgresql:/var/lib/postgresql`, which is explicitly accounting for [docker-library/postgres#1259](https://github.com/docker-library/postgres/pull/1259))

---

If your two directories (denoted below as `PGDATAOLD` and `PGDATANEW`) do not follow this structure, then the following may also be used (but will be slower):

```console
$ docker run --rm \
	--mount 'type=bind,src=PGDATAOLD,dst=/var/lib/postgresql/OLD/docker' \
	--mount 'type=bind,src=PGDATANEW,dst=/var/lib/postgresql/NEW/docker' \
	--env 'PGDATAOLD=/var/lib/postgresql/OLD/docker' \
	--env 'PGDATANEW=/var/lib/postgresql/NEW/docker' \
	tianon/postgres-upgrade:OLD-to-NEW

...
```

More concretely, assuming `OLD` of `17`, `NEW` of `18`, `PGDATAOLD` of `/mnt/bigdrive/postgresql-17`, and `PGDATANEW` of `/mnt/bigdrive/postgresql-18`:

```console
$ docker run --rm \
	--mount 'type=bind,src=/mnt/bigdrive/postgresql-17,dst=/var/lib/postgresql/17/docker' \
	--mount 'type=bind,src=/mnt/bigdrive/postgresql-18,dst=/var/lib/postgresql/18/docker' \
	--env 'PGDATAOLD=/var/lib/postgresql/17/docker' \
	--env 'PGDATANEW=/var/lib/postgresql/18/docker' \
	tianon/postgres-upgrade:17-to-18

...
```

(which assumes that your previous `postgres:17` instance was running with `-v /mnt/bigdrive/postgresql-17:/var/lib/postgresql/data`, and your new `postgres:18` instance will run with `-v /mnt/bigdrive/postgresql-18:/var/lib/postgresql/18/docker`, although that's [not recommended](https://github.com/docker-library/postgres/pull/1259#issuecomment-3433788598))

---

Putting it all together:

```console
$ mkdir -p postgres-upgrade-testing
$ cd postgres-upgrade-testing
$ OLD='17'
$ NEW='18'

$ docker run -dit \
	--name postgres-upgrade-testing \
	--env POSTGRES_PASSWORD='password' \
	--env POSTGRES_INITDB_ARGS='--data-checksums' \
	--mount "type=bind,src=$PWD,dst=/var/lib/postgresql" \
	--env PGDATA="/var/lib/postgresql/$OLD/docker" \
	--pull always \
	"postgres:$OLD"
$ sleep 5
$ docker logs --tail 100 postgres-upgrade-testing

$ # let's get some testing data in there
$ docker exec -it \
	-u postgres \
	postgres-upgrade-testing \
	pgbench -i -s 10

$ docker stop postgres-upgrade-testing
$ docker rm postgres-upgrade-testing

$ docker run --rm \
	--env POSTGRES_INITDB_ARGS='--data-checksums' \
	--mount "type=bind,src=$PWD,dst=/var/lib/postgresql" \
	--env "PGDATAOLD=/var/lib/postgresql/$OLD/docker" \
	--env "PGDATANEW=/var/lib/postgresql/$NEW/docker" \
	--pull always \
	"tianon/postgres-upgrade:$OLD-to-$NEW" \
	--link

$ docker run -dit \
	--name postgres-upgrade-testing \
	--env POSTGRES_PASSWORD='password' \
	--env POSTGRES_INITDB_ARGS='--data-checksums' \
	--mount "type=bind,src=$PWD,dst=/var/lib/postgresql" \
	--env PGDATA="/var/lib/postgresql/$NEW/docker" \
	--pull always \
	"postgres:$NEW"
$ sleep 5
$ docker logs --tail 100 postgres-upgrade-testing

$ # can now (probably) safely remove "$OLD"
$ sudo rm -rf "$OLD"
```
