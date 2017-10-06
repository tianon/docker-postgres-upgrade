#!/bin/bash
set -e

if [ "$#" -eq 0 -o "${1:0:1}" = '-' ]; then
	set -- pg_upgrade "$@"
fi

if [ "$1" = 'pg_upgrade' -a "$(id -u)" = '0' ]; then
	mkdir -p "$PGDATAOLD" "$PGDATANEW"
	chmod 700 "$PGDATAOLD" "$PGDATANEW"
	chown postgres .
	chown -R postgres "$PGDATAOLD" "$PGDATANEW"
	exec gosu postgres "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'pg_upgrade' ]; then
	if [ ! -s "$PGDATANEW/PG_VERSION" ]; then
		PGDATA="$PGDATANEW" eval "initdb $POSTGRES_INITDB_ARGS"
	fi
fi

exec "$@"
