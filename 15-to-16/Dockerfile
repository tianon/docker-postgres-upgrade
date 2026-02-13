#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM postgres:16-trixie

RUN sed -i 's/$/ 15/' /etc/apt/sources.list.d/pgdg.list

RUN set -eux; \
	apt-get install --update -y --no-install-recommends \
		postgresql-15='15.16-1.pgdg13+1' \
	; \
	apt-get dist-clean

ENV PGBINOLD /usr/lib/postgresql/15/bin
ENV PGBINNEW /usr/lib/postgresql/16/bin
RUN set -eux; \
	"$PGBINOLD/postgres" --version; \
	"$PGBINNEW/postgres" --version

ENV PGDATAOLD /var/lib/postgresql/15/data
ENV PGDATANEW /var/lib/postgresql/16/data

RUN install \
		--verbose \
		--owner postgres \
		--group postgres \
		--mode 1777 \
		--directory \
		"$PGDATAOLD" \
		"$PGDATANEW"

WORKDIR /var/lib/postgresql

COPY docker-upgrade /usr/local/bin/

ENTRYPOINT ["docker-upgrade"]

# recommended: --link
CMD ["pg_upgrade"]
