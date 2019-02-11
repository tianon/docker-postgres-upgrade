FROM postgres:11

COPY --from=postgres:10 /usr/lib/postgresql/10 /usr/lib/postgresql/10/
COPY --from=postgres:10 /usr/share/postgresql/10 /usr/share/postgresql/10/

ENV PGBINOLD /usr/lib/postgresql/10/bin
ENV PGBINNEW /usr/lib/postgresql/11/bin

ENV PGDATAOLD /var/lib/postgresql/10/data
ENV PGDATANEW /var/lib/postgresql/11/data

RUN mkdir -p "$PGDATAOLD" "$PGDATANEW" \
	&& chown -R postgres:postgres /var/lib/postgresql

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]
