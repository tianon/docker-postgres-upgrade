FROM postgres:16-bookworm

RUN sed -i 's/$/ 15/' /etc/apt/sources.list.d/pgdg.list

RUN apt-get update && apt-get install -y --no-install-recommends \
		postgresql-15 \
	&& rm -rf /var/lib/apt/lists/*

ENV PGBINOLD /usr/lib/postgresql/15/bin
ENV PGBINNEW /usr/lib/postgresql/16/bin

ENV PGDATAOLD /var/lib/postgresql/15/data
ENV PGDATANEW /var/lib/postgresql/16/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
	&& chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]
