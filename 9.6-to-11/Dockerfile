FROM postgres:11

RUN sed -i 's/$/ 9.6/' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends \
		postgresql-9.6=9.6.21-1.pgdg90+1 \
		postgresql-contrib-9.6=9.6.21-1.pgdg90+1 \
	&& rm -rf /var/lib/apt/lists/*

ENV PGBINOLD /usr/lib/postgresql/9.6/bin
ENV PGBINNEW /usr/lib/postgresql/11/bin

ENV PGDATAOLD /var/lib/postgresql/9.6/data
ENV PGDATANEW /var/lib/postgresql/11/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
	&& chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]
