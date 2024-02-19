# `pg_upgrade`, Docker style

This is a PoC for using `pg_upgrade` inside Docker to upgrade from an old PostgreSQL data directory to a new one -- learn from it, adapt it for your needs; don't expect it to work as-is!

(Source for this image is available at [https://github.com/tianon/docker-postgres-upgrade](https://github.com/tianon/docker-postgres-upgrade).)

Tags of this image are of the format `OLD-to-NEW`, where `OLD` represents the version of PostgreSQL you are _currently_ running, and `NEW` represents the version of PostgreSQL you would like to upgrade to.

In order to get good performance, it is recommended to run this Docker image with the `--link` option (see [`pg_upgrade` documentation](https://www.postgresql.org/docs/9.5/static/pgupgrade.html) for more details, and the below sections for examples).

## Prerequisites

For a migration, you only need to have Docker installed, know where your current Postgres data lives, and where you want to create the new data directory.

> [!WARNING]
> Always create a backup of the data before attempting a migration so you can restore in the event of data loss.

## How does it work?

This image runs `pg_upgrade` to migrate the data from an old to a newer version of Postgres. Note that it does not use your existing Postgres Docker image that runs the actual database.

For the upgrade procedure, you have to mount two directories into the container:

* The old PostgreSQL data directory, from which you want to upgrade
* The new (empty) PostgreSQL data directory, to which the upgraded data will be written (by this image)

There are two ways your existing data may be laid out on your file system already:

1. A directory with subdirectories for each Postgres version (e.g. `/mnt/bigdrive/postgresql/9.4` and `/mnt/bigdrive/postgresql/9.5`).
2. A single directory containing just the Postgres data (e.g. `/mnt/bigdrive/postgresql/`)

The examples in this README are always Docker bind mounts, but the same applies to Docker named volumes.

Depending on which method you use, follow any of the below sections.

### Subdirectories for each Postgres version

For this to be feasible, your directory structure should look something like this:

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

This assumes that your previous `postgres:9.4` Docker container was running with `-v /mnt/bigdrive/postgresql/9.4/data:/var/lib/postgresql/data`, and your new `postgres:9.5` container will run with `-v /mnt/bigdrive/postgresql/9.5/data:/var/lib/postgresql/data`.

Note that this uses `--link` and will be faster than the single directory method below.

### Single directory with Postgres data

If you previously only had a single directory for Postgres data (denoted below as `PGDATAOLD`), you must create a new one and (`PGDATANEW`). This will, however, be slower:

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

This assumes that your previous `postgres:9.4` container was running with `-v /mnt/bigdrive/postgresql-9.4:/var/lib/postgresql/data`, and your new `postgres:9.5` container will run with `-v /mnt/bigdrive/postgresql-9.5:/var/lib/postgresql/data`.

### Usage with Docker Named Volumes

If your Postgres data is stored in Docker named volumes, you can use the same commands as above. Just replace the directory paths with the names of your named volumes. For example, if you have a named volume called `pgdata-9.4` and another called `pgdata-9.5`, you can use the following commands:

```console
$ docker run --rm \
  -v pgdata-9.4:/var/lib/postgresql/OLD/data \
  -v pgdata-9.5:/var/lib/postgresql/NEW/data \
  tianon/postgres-upgrade:OLD-to-NEW
```

## Example

Putting it all together, you can use this image as follows, assuming you want to upgrade from Postgres 9.4 to 9.5.

We first create a directory for our test and set the old and new versions as variables in our current shell session:

```bash
mkdir -p postgres-upgrade-testing
cd postgres-upgrade-testing
OLD='9.4'
NEW='9.5'
```

Then, we pull the old Postgres image (from which we want to migrate) and create a container for the old version named `postgres-upgrade-testing`:

```bash
docker pull "postgres:$OLD"
docker run -dit \
  --name postgres-upgrade-testing \
  -e POSTGRES_PASSWORD=password \
  -v "$PWD/$OLD/data":/var/lib/postgresql/data \
  "postgres:$OLD"
docker logs -f postgres-upgrade-testing
```

We should now see some logs indicating that the database is ready to accept connections. When that is the case, press `Ctrl-C` to exit the logs.

Let's create some test data:

```bash
docker exec -it \
  -u postgres \
  postgres-upgrade-testing \
  pgbench -i -s 10
```

Now, we can stop and remove the Postgres container – your data still lives in `$OLD/data`.

```bash
docker stop postgres-upgrade-testing
docker rm postgres-upgrade-testing
```

We begin the migration by pulling the image from this repository and running the migration container:

```bash
docker run --rm \
  -v "$PWD":/var/lib/postgresql \
  "tianon/postgres-upgrade:$OLD-to-$NEW" \
  --link
```

When this succeeded, we can start the new Postgres version in a container and check that the data is still there:

```bash
docker pull "postgres:$NEW"
docker run -dit \
  --name postgres-upgrade-testing \
  -e POSTGRES_PASSWORD=password \
  -v "$PWD/$NEW/data":/var/lib/postgresql/data \
  "postgres:$NEW"
docker logs -f postgres-upgrade-testing
```

This should show the same logs as before. `Ctrl-C` to exit the logs.

Now you can safely remove `$OLD`:

```bash
sudo rm -rf "$OLD"
```

That's it!
